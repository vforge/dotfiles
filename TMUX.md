# tmux setup

Persistent terminal sessions with Vim-style navigation, a Tokyo Night status bar, and auto-save/restore via TPM plugins.

Config: `settings/tmux.conf.symlink` → `~/.tmux.conf`

---

## Installation

### 1. Install tmux

```bash
brew install tmux        # macOS
sudo apt install tmux    # Debian/Ubuntu
```

### 2. Install TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Link config (handled by install.sh)

```bash
bash ~/.dotfiles/install/symlinks.sh
```

Or manually:

```bash
ln -sf ~/.dotfiles/settings/tmux.conf.symlink ~/.tmux.conf
```

### 4. Install plugins

Start tmux, then press `C-a I` to fetch all plugins.

---

## Prefix

`Ctrl+a` (remapped from the default `Ctrl+b`)

`C-a C-a` sends the prefix through to a nested tmux or inner app.

---

## Key bindings

### Sessions

| Key | Action |
|-----|--------|
| `C-a d` | Detach (session keeps running) |
| `C-a $` | Rename session |
| `C-a s` | Switch sessions (interactive) |
| `t` | Attach/create the default `main` session |
| `t <name>` | Attach/create a named session |

### Windows

| Key | Action |
|-----|--------|
| `C-a c` | New window (inherits cwd) |
| `C-a 1–9` | Switch to window # |
| `C-a n / p` | Next / previous window |
| `C-a ,` | Rename window |
| `C-a &` | Kill window |
| `C-a w` | Visual window picker |

### Panes

| Key | Action |
|-----|--------|
| `C-a \|` | Split vertically |
| `C-a -` | Split horizontally |
| `C-a h/j/k/l` | Move between panes (Vim-style) |
| `C-a H/J/K/L` | Resize pane (repeatable) |
| drag border | Resize pane with mouse |
| `C-a z` | Zoom pane (toggle fullscreen) |
| `C-a !` | Break pane into new window |
| `C-a x` | Kill pane |
| `C-a Space` | Cycle layouts |
| `C-a { / }` | Swap pane left / right |

### Copy mode (Vi)

| Key | Action |
|-----|--------|
| `C-a Enter` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy to clipboard (pbcopy/xclip) |
| `/ ` or `?` | Search forward / backward |
| `n / N` | Next / previous result |
| `g / G` | Top / bottom of scrollback |
| `Ctrl-u / Ctrl-d` | Half-page up / down |
| `q` or `Esc` | Exit copy mode |

### Config

| Key | Action |
|-----|--------|
| `C-a r` | Reload config |
| `C-a I` | Install plugins (TPM) |
| `C-a U` | Update plugins |
| `C-a ?` | Open in-terminal cheatsheet |

---

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm).

| Plugin | Purpose |
|--------|---------|
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sane defaults |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions across restarts |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save every 15 min, auto-restore on start |
| [tmux-cpu](https://github.com/tmux-plugins/tmux-cpu) | CPU/RAM metrics in status bar |
| [tmux-battery](https://github.com/tmux-plugins/tmux-battery) | Battery % in status bar |

Resurrect/continuum binds: `C-a Ctrl+s` (save), `C-a Ctrl+r` (restore).

---

## Status bar

Tokyo Night color scheme. Bottom bar shows:

```
  <session>   window list          CPU% │ RAM% │ battery% │ HH:MM
```

---

## Custom scripts

### `t` — tmux entrypoint (`bin/t`)

Smart attach/create wrapper:

```bash
t            # attach or create "main" session
t work       # attach or create a named session
```

Works both outside tmux (creates/attaches) and inside (switches client).

### `tmux-help` — in-terminal cheatsheet (`bin/tmux-help`)

Colorized keybind reference, bound to `C-a ?`:

```bash
tmux-help    # run directly
```

Opens via popup so you never leave the current session.
