# herdr keys

Terminal workspace manager for AI coding agents. Prefix is **`C-a`** (same as tmux), so `C-a h` means press `C-a`, release, then `h`. `S-` means Shift.

Config: `settings/herdr.toml.symlink` → `~/.config/herdr/config.toml` · Plugins: `settings/herdr-plugins.txt` · Installed by `install/symlinks-work.sh`

`C-a ?` shows every binding in herdr itself.

---

## Essentials

| Key | Action |
|-----|--------|
| `C-a ?` | Keybinding help |
| `C-a s` | Settings |
| `C-a g` | Session navigator |
| `C-a w` | Workspace picker |
| `C-a b` | Toggle sidebar |
| `C-a o` | Jump to the pane behind the latest notification |
| `C-a e` | Open pane scrollback in `$EDITOR` |
| `C-a C-n` / `C-a C-p` | Next / previous agent (across workspaces) |
| `C-a r` | Reload config |
| `C-a q` | Detach (server and agents keep running) |

## Workspaces

| Key | Action |
|-----|--------|
| `C-a S-n` | New workspace |
| `C-a S-w` | Rename workspace |
| `C-a S-d` | Close workspace |
| `C-a S-1–9` | Jump to workspace 1–9 |

## Tabs

| Key | Action |
|-----|--------|
| `C-a c` | New tab |
| `C-a n` / `C-a p` | Next / previous tab |
| `C-a 1–9` | Jump to tab 1–9 |
| `C-a S-t` | Rename tab |
| `C-a S-x` | Close tab |

## Panes

| Key | Action |
|-----|--------|
| `C-a v` or `C-a \|` | Split side by side |
| `C-a -` | Split stacked |
| `C-a h/j/k/l` | Focus left / down / up / right |
| `C-a Tab` / `C-a S-Tab` | Cycle panes |
| `C-a ;` | Last pane (back and forth) |
| `C-a C-k` | Clear pane |
| `C-a z` | Zoom |
| `C-a x` | Close pane |
| `C-a S-p` | Rename pane |
| `C-a S-h/j/k/l` | Resize left / down / up / right |
| `C-a S-r` | Resize mode (then `h` `j` `k` `l`) |
| `C-a [` or `C-a Enter` | Copy mode |

Swapping panes is unbound; `S-h/j/k/l` resize instead, like tmux.

## Plugins

| Key | Plugin | Action |
|-----|--------|--------|
| `C-a Space` | herdr-bar | Command bar: fuzzy-jump to any tab, agent, repo or branch |
| `C-a ,` | herdr-radar | Settings popup for the agents/spaces panels |
| `C-a a` | herdr-radar | Flip agents panel order (active ↔ recent) |
| `C-a d` | reviewr | Review the agent's diff, send comments back |
| `C-a f` / `C-a S-f` | file-viewer | File viewer in a split / new tab |
| `C-a m` | memex | Search past agent sessions |
| `C-a S-m` | memex | Resume last session |
| `C-a S-g` | worktrunk | Switch to / create a git worktree (replaces herdr's built-in) |
| `C-a i` | plugin-manager | Install, update, enable, disable plugins |

Worktree merge/remove and other plugin actions without a key: `C-a i`, or `herdr plugin action list`. Update plugins with `herdr plugin update`.

## Popups

Open over the layout and close when you quit the tool.

| Key | Tool |
|-----|------|
| `C-a C-g` | lazygit |
| `C-a y` | yazi |
| `C-a t` | btop |

---

## Sessions

herdr saves the layout (workspaces, tabs, panes, folders) on its own and resumes Claude conversations when it restarts, so after a crash just run `h`.

| Command | Does |
|---------|------|
| `h` | Attach to herdr (starts the server and restores the last session if needed) |
| `herdr-save [name]` | Keep a named copy of the current layout in `~/.config/herdr/saved/` |
| `herdr-restore` | Pick a saved copy or one of herdr's auto snapshots (every ≤15 min) with fzf, then restart into it |
| `herdr-restore <name>` | Restore a named copy directly |

`h --session <name>` runs a separate persistent session (e.g. work vs personal) with its own layout; `herdr-save`/`herdr-restore` only handle the default one. `h --remote <ssh-host>` attaches to herdr on another machine.

`herdr-restore` stops the server, which ends every pane's processes, so run it from a plain terminal, not inside herdr. The session it replaces is kept as `saved/before-restore_*`.

---

## Gotchas

- Plugins installed while the server is running don't start their background daemons until the next herdr start. Radar needs `herdr plugin action invoke hhdebb.herdr-radar.state-start` after a fresh install, or the sidebar rows render empty.
- Radar writes managed blocks into `config.toml` and puts your absolute home path in the tab-bar command; the `homepath` git filter (`.gitattributes`) commits it as `$HOME`.
- Radar's agent logos need its icon font; restart Ghostty after installing it.
- Ghostty doesn't send Option as Alt, so `alt+` bindings don't fire; custom keys use `ctrl+` after the prefix instead.
- `herdr config check` validates the config before you reload it.
- `herdr server stop` kills every process in every pane, agents included. Use `C-a q` to detach and `C-a r` to reload config instead.
