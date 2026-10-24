# 🦄 dotfiles 🛠️

> ⚠️ Personal configuration. Use at your own risk — no warranty whatsoever.

Modern zsh setup: **zinit** + **starship** + **zoxide**

## 🚀 Setup (new machine)

### Simple mode (servers, headless Linux)

Installs core configs + system packages only.

```bash
git clone https://github.com/vforge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && bash install.sh simple
exec zsh
```

Supports: Ubuntu, Debian, Raspberry Pi OS, CachyOS.

### Workstation mode (macOS desktop)

Full setup: configs + Homebrew + apps + macOS defaults.

```bash
git clone https://github.com/vforge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && bash install.sh work
exec zsh
```

zinit auto-installs on first launch if missing.

### Running individual steps

`simple`/`work` are shortcuts. Run any step on its own, or `bash install.sh` with no arguments to be asked y/N per step:

```bash
bash install.sh links        # core symlinks
bash install.sh work-links   # workstation symlinks, herdr plugins, g-today agent
bash install.sh brew mas     # Homebrew + Brewfile (no upgrades), App Store apps
bash install.sh macos        # macOS defaults
bash install.sh packages     # apt/pacman packages (Linux)
```

Existing files and macOS settings you've already set are kept and reported. Add `--force` to replace them (files are backed up first).

## 📦 Stack

| Component | What it does | Docs |
|-----------|-------------|------|
| **zsh** | Shell | [z.sh](https://zsh.sourceforge.io/) |
| **zinit** | Plugin manager (auto-installs) | [GitHub](https://github.com/zdharma-continuum/zinit) |
| **starship** | Cross-shell prompt (`~/.starship.toml`) | [starship.rs](https://starship.rs/) |
| **zoxide** | Fuzzy directory jumping (`z proj<TAB>`) | [GitHub](https://github.com/ajeetdsouza/zoxide) |
| **zsh-autosuggestions** | Inline command suggestions | [GitHub](https://github.com/zsh-users/zsh-autosuggestions) |
| **zsh-syntax-highlighting** | Syntax highlighting in the shell | [GitHub](https://github.com/zsh-users/zsh-syntax-highlighting) |
| **zsh-history-substring-search** | History search (Up/Down arrows) | [GitHub](https://github.com/zsh-users/zsh-history-substring-search) |
| **fzf** | Fuzzy finder (Ctrl+T, Ctrl+R) | [GitHub](https://github.com/junegunn/fzf) |

## 🔧 Git productivity plugins

- **supercrabtree/k** — Search git log by keyword (`k <keyword>`) — [GitHub](https://github.com/supercrabtree/k)
- **peterhurford/git-it-on.zsh** — Git helper aliases — [GitHub](https://github.com/peterhurford/git-it-on.zsh)
- **skx/sysadmin-util** — Sysadmin utility functions — [GitHub](https://github.com/skx/sysadmin-util)

## 🔌 Tool integrations

- **pnpm** — PATH configured via pnpm installer snippet — [pnpm.io](https://pnpm.io/)
- **Google Cloud SDK** — Auto-loaded if installed — [cloud.google.com/sdk](https://cloud.google.com/sdk)
- **LM Studio CLI** (`lms`) — PATH added for local model inference — [GitHub](https://github.com/lmstudio-ai)
- **Pi coding agent** — Personal Pi package + `pissh` notes — [PI.md](PI.md)
- **rbenv** — Ruby version manager (loaded if available) — [rbenv.github.io](https://github.com/rbenv/rbenv)
- **GRC** — Colorizes unix tools (loaded if available) — [GitHub](https://github.com/garabik/grc)

## 🔨 CLI Tools

Custom scripts in `bin/` — git helpers, kubectl wrappers, SSH provisioning, and more.
→ Full list: [TOOLS.md](TOOLS.md)

## 🖥️ tmux

Persistent sessions, Vim-style navigation, Tokyo Night status bar, auto-save/restore.
→ Setup & keybinds: [TMUX.md](TMUX.md)

## 🐑 herdr

Workspace manager for AI coding agents, with tmux-style keys and plugins.
→ Keys: [HERDR.md](HERDR.md)

## 📸 g today

`git today` (alias in `gitconfig`) stages everything, commits as `chore: <timestamp>`, and pushes if the repo has an `origin`.

On macOS, a launchd agent runs it hourly in every repo listed in `~/.config/g-today/repos` (one path per line, `~` allowed, `#` comments). The list is local and untracked; edits apply on the next run.

```bash
echo "~/some/repo" >> ~/.config/g-today/repos          # add a repo
launchctl kickstart "gui/$(id -u)/com.dotfiles.g-today"  # run now
tail ~/Library/Logs/g-today.log                         # check output
```

Script: `bin/g-today-all`. Agent: `settings/g-today.plist`, installed by `install/symlinks-work.sh`.

## 🔄 Updating existing machine

From anywhere:
```bash
dotfiles-update          # Pull + ask y/N per step
dotfiles-update simple   # Force simple mode
dotfiles-update work     # Force workstation mode
```

Or manually:
```bash
cd ~/.dotfiles && git pull && bash install.sh
```

## 📝 Notes

- Node.js/Python shown in prompt **only** inside project directories
- Git repos show full path (not truncated to repo root)
- Existing configs are never replaced without `--force`; with it they're backed up as `.backup` (timestamped if one already exists)
