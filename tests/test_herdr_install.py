"""Exercise installers with a temporary HOME and mocked external services."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class HerdrInstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        base = Path(self.temp.name).resolve()
        self.repo = base / "dotfiles"
        self.home = base / "home"
        self.bin = base / "bin"
        for directory in (self.repo, self.home, self.bin):
            directory.mkdir()
        shutil.copy(ROOT / "install.sh", self.repo)
        shutil.copytree(ROOT / "install", self.repo / "install")
        shutil.copytree(ROOT / "settings", self.repo / "settings")
        self.log = base / "commands.log"
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "COMMAND_LOG": str(self.log),
            "TEST_OS": "Linux",
        }
        self.mock("uname", 'echo "$TEST_OS"')
        self.mock("git", 'echo "git $*" >> "$COMMAND_LOG"')
        self.mock("brew", 'echo "brew $*" >> "$COMMAND_LOG"')
        self.mock("memex", "exit 0")
        self.mock("launchctl", 'echo "launchctl $*" >> "$COMMAND_LOG"')
        self.mock("mas", "exit 0")
        self.mock("herdr", '''
            echo "herdr $*" >> "$COMMAND_LOG"
            case "$*" in
              "plugin list")
                for plugin in "$HOME"/installed/*; do
                  [ -f "$plugin" ] || continue
                  printf 'github:%s@ref\\n' "$(cat "$plugin")"
                done ;;
              "plugin install -y "*)
                mkdir -p "$HOME/installed"
                printf '%s' "$4" > "$HOME/installed/$(echo "$4" | tr / _)" ;;
              --skill) echo '# Mock Herdr skill' ;;
              *) exit 1 ;;
            esac
        ''')

    def mock(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def run_install(self, *args):
        result = subprocess.run(
            ["/bin/bash", str(self.repo / "install.sh"), *args],
            env=self.env, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def commands(self):
        return self.log.read_text() if self.log.exists() else ""

    def test_standalone_links_and_installs_plugins_on_linux(self):
        self.run_install("herdr")
        expected = {
            ".config/herdr/config.toml": "herdr.toml.symlink",
            ".config/herdr/plugins/config/hhdebb.herdr-radar/config.toml": "herdr-radar.toml.symlink",
            ".config/herdr/plugins/config/hhdebb.herdr-radar/render.cjs": "herdr-radar-render.cjs",
            ".config/herdr/plugins/config/persiyanov.reviewr/config.toml": "herdr-reviewr.toml.symlink",
            ".config/herdr/plugins/config/worktrunk/config.toml": "herdr-worktrunk.toml.symlink",
            ".memex/config.toml": "memex.toml.symlink",
        }
        for target, source in expected.items():
            self.assertEqual((self.home / target).resolve(), self.repo / "settings" / source)
        self.assertIn("Mock Herdr skill", (self.home / ".claude/skills/herdr/SKILL.md").read_text())
        plugins = [line for line in (self.repo / "settings/herdr-plugins.txt").read_text().splitlines()
                   if line and not line.startswith("#")]
        self.assertEqual(self.commands().count("herdr plugin install -y "), len(plugins))
        self.assertNotIn("brew ", self.commands())
        self.assertNotIn("launchctl ", self.commands())
        self.assertFalse((self.home / ".vimrc").exists())

    def test_repeat_skips_installed_plugins(self):
        self.run_install("herdr")
        self.log.write_text("")
        self.run_install("herdr")
        self.assertNotIn("plugin install", self.commands())

    def test_preserves_config_and_force_backs_it_up(self):
        config = self.home / ".config/herdr/config.toml"
        config.parent.mkdir(parents=True)
        config.write_text("# local config\n")
        self.run_install("herdr")
        self.assertFalse(config.is_symlink())
        self.assertEqual(config.read_text(), "# local config\n")
        self.run_install("--force", "herdr")
        self.assertTrue(config.is_symlink())
        self.assertEqual(config.with_name("config.toml.backup").read_text(), "# local config\n")

    def test_without_herdr_still_links_configs(self):
        (self.bin / "herdr").unlink()
        output = self.run_install("herdr")
        self.assertIn("herdr not found", output)
        self.assertTrue((self.home / ".config/herdr/config.toml").is_symlink())
        self.assertFalse((self.home / ".claude/skills/herdr/SKILL.md").exists())

    def test_macos_starts_memex_service(self):
        self.env["TEST_OS"] = "Darwin"
        self.run_install("herdr")
        self.assertIn("brew services start memex", self.commands())

    def test_work_links_no_longer_sets_up_herdr(self):
        self.env["TEST_OS"] = "Darwin"
        (self.home / "Library/LaunchAgents").mkdir(parents=True)
        self.run_install("work-links")
        self.assertTrue((self.home / ".vimrc").is_symlink())
        self.assertIn("launchctl ", self.commands())
        self.assertFalse((self.home / ".config/herdr").exists())
        self.assertFalse((self.home / ".memex").exists())
        self.assertNotIn("herdr ", self.commands())
        self.assertNotIn("git ", self.commands())

    def test_work_shortcut_keeps_herdr_setup(self):
        self.env["TEST_OS"] = "Darwin"
        for name in ("symlinks.sh", "symlinks-work.sh", "osx-config.sh"):
            (self.repo / "install" / name).write_text("#!/bin/sh\nexit 0\n")
        (self.repo / "mac-apps.txt").write_text("# no apps in this fixture\n")
        self.run_install("work")
        self.assertTrue((self.home / ".config/herdr/config.toml").is_symlink())
        self.assertEqual(self.commands().count("herdr plugin list"), 1)


if __name__ == "__main__":
    unittest.main()
