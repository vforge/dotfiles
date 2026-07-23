# cmux setup

cmux is a Ghostty-based terminal workspace manager with tabs, panes, agent integrations, notifications, browser splits, and a CLI.

Install is handled by the workstation `Brewfile`:

```bash
brew install --cask cmux
brew install drolosoft/tap/cmux-resurrect
```

The `cmux` CLI is installed with the app; `cmux-resurrect` also provides the short `crex` command.

## Core tools

### cmux-resurrect / crex

Save, restore, template, and auto-save cmux/Ghostty workspaces.

```bash
crex save my-day
crex restore my-day
crex list
crex template list
crex watch my-day --daemon
```

Useful built-in templates include `claude`, `code`, `explore`, `logs`, `system`, `ide`, `quad`, and `triple`.

Install the agent reference skill so AI coding tools know how to drive `crex`:

```bash
crex skill install
```

### Agent hooks

cmux can hook into coding agents for session restore, feed approvals, and notifications.

```bash
cmux hooks setup                 # install hooks for supported agents on PATH
cmux hooks setup --agent pi
cmux hooks setup --agent codex
cmux hooks setup --agent opencode
cmux hooks setup --agent gemini
```

See supported agents:

```bash
cmux hooks setup --help
cmux docs agents
```

## Useful cmux features

### Dock controls

Custom project/global buttons and actions for the right sidebar.

```bash
cmux docs dock
```

Config locations:

```text
.cmux/dock.json
~/.config/cmux/dock.json
```

Good uses: run dev server, tests, logs, Docker compose, or open a browser split.

### Custom sidebars

Runtime-interpreted custom right-sidebar views.

```bash
cmux docs sidebars
```

Location:

```text
~/.config/cmux/sidebars/
```

### Browser automation

Useful for web-app development and coding agents.

```bash
cmux browser open http://localhost:3000
cmux browser snapshot
cmux browser screenshot --out /tmp/page.png
cmux browser click "button[type=submit]"
cmux browser eval "document.title"
```

### Diff, markdown, todos, and status

```bash
cmux diff --unstaged
cmux markdown open README.md
cmux todo add "Fix auth flow"
cmux set-status build passing --icon check --color '#00ff00'
cmux set-progress 0.5 --label "Running tests"
```

## Config files

cmux-owned settings:

```text
~/.config/cmux/cmux.json
```

Ghostty terminal behavior read by cmux:

```text
~/.config/ghostty/config
```

Use Ghostty config for terminal theme, font, transparency, blur, cursor, and terminal keybinds.

Useful commands:

```bash
cmux settings path
cmux config doctor
cmux themes list
cmux themes set "Catppuccin Mocha"
cmux reload-config
```

Before adding cmux configs to dotfiles, clean them first: do not commit local session state, machine-specific paths, credentials, or personal identifiers.
