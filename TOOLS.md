# Tools

Custom CLI scripts in `bin/`. All available on PATH when dotfiles are installed.

## SSH & Remote

| Tool | Description | Docs |
|------|-------------|------|
| **ssh-readonly-user/** | Provision restricted readonly users on remote servers (for agents) | [README](bin/ssh-readonly-user/README.md) |
| **pissh** | Wrapper — runs `pi` (coding agent) over SSH to a remote machine | — |

## Git

| Tool | Description |
|------|-------------|
| **git-amend** / **git-amend2** | Amend last commit with/without reword |
| **git-big-object-report** | Find the largest objects in repo history |
| **git-conflicts** | Show files with merge conflicts |
| **git-copy-branch-name** | Copy current branch name to clipboard |
| **git-credit** | Show commit stats for a user |
| **git-cut-branch** | Move commits from one branch to another |
| **git-delete-local-merged** | Delete local branches already merged to main |
| **git-empty-commit** | Create an empty commit (useful for CI triggers) |
| **git-find-object** | Find git objects by content/hash |
| **git-ignore** | Quick-add patterns to .gitignore |
| **git-incoming** / **git-outgoing** | Show commits that would be pulled/pushed |
| **git-ls-object-refs** | List refs pointing to a specific object |
| **git-nuke** | Force-remove a file from entire history |
| **git-object-deflate** | Show size difference between stored and raw objects |
| **git-pruneall** / **git-prune-merged-branches** | Aggressive branch cleanup |
| **git-rank-contributors** | Rank contributors by commit count |
| **git-rel** | Create a lightweight tag for current commit |
| **git-remove-file** | Remove a file from the current commit |
| **git-reup** | Rebase onto upstream |
| **git-sh** | Interactive git shell with helpers |
| **git-thanks** | Generate contributor thanks message |
| **git-track** / **git-track2** | Set up tracking for current branch |
| **git-undo** | Undo last commit (keep changes) |
| **git-unpushed** / **git-unpushed-stat** | Show commits not yet pushed (with stats) |
| **git-up** | Pull and rebase in one step |
| **git-wtf** | Full repo status overview (branches, stash, conflicts, unpushed) |

## System & DevOps

| Tool | Description |
|------|-------------|
| **kubekurwa** | Kubectl wrapper for multi-cluster management (dev/prod) |
| **k9s-dev** / **k9s-prod** | Launch k9s with dev or prod context |
| **mysql-rename-database** | Safely rename a MySQL database |
| **pidkill** | Kill processes by name pattern |
| **autoscreen** | Resume or start a screen session with ssh-agent forwarding |

## File & Text

| Tool | Description |
|------|-------------|
| **e** | Quick editor shortcut (opens configured editor) |
| **fix-line-endings** | Convert CRLF → LF in files |
| **fix-rw** | Fix file permissions recursively |
| **headers** | Add license/project headers to files |
| **imgcat** | Display images in terminal (tmux + iTerm compatible) |
| **license** | Generate or display license text |
| **mirror** | Mirror a website offline with wget |
| **prune-dirs** | Remove empty directories recursively |
| **rename-mac** | Batch rename files/mac addresses |
| **search** | Quick recursive string search in a directory |
| **colordump** | Dump terminal color palette for testing |

## Dotfiles & Releases

| Tool | Description |
|------|-------------|
| **dotfiles-update** | Pull latest dotfiles and re-apply config |
| **dot-update** | Shortcut to dotfiles-update |
| **curseforge-make** / **curseforge-release** | CurseForge mod packaging helpers |

## Misc

| Tool | Description |
|------|-------------|
| **argv** | Print all script arguments (debugging) |
| **ip** | Show IPv4 address(es) for network interface(s) |
