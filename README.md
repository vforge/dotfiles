# 🦄 dotfiles 🦄

Modern zsh setup: **zinit** + **starship** + **fuzzy directory jumping**.

## Setup (new machine)

### 1. Clone
```bash
git clone https://github.com/vforge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Install dependencies
```bash
# macOS
brew bundle --file=Brewfile

# Linux (Ubuntu/Debian)
sudo apt install starship zsh curl git
```

### 3. Create symlinks
```bash
bash install/symlinks.sh --force
```

### 4. Restart shell
```bash
exec zsh
```

zinit auto-installs on first launch if missing.

## Stack

| Component | What it does |
|-----------|-------------|
| **zsh** | Shell |
| **zinit** | Plugin manager (auto-installs) |
| **starship** | Cross-shell prompt (`~/.starship.toml`) |
| **rupa/z** | Fuzzy directory jumping (`z proj<TAB>`) |
| **zsh-autocomplete** | Tab completion + autosuggestions |
| **fzf** | Fuzzy finder (Ctrl+T, Ctrl+R) |

## Updating existing machine

```bash
cd ~/.dotfiles && git pull && bash install/symlinks.sh --force
```

## Notes

- Node.js/Python shown in prompt **only** inside project directories
- Git repos show full path (not truncated to repo root)
- Backups of old configs saved as `.bak` files on first run
