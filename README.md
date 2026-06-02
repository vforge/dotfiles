# 🦄 dotfiles 🦄

Modern zsh setup: **zinit** + **starship** + **zoxide**.

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

## Git productivity plugins

- **supercrabtree/k** — Search git log by keyword (`k <keyword>`) — [GitHub](https://github.com/supercrabtree/k)
- **peterhurford/git-it-on.zsh** — Git helper aliases — [GitHub](https://github.com/peterhurford/git-it-on.zsh)
- **skx/sysadmin-util** — Sysadmin utility functions — [GitHub](https://github.com/skx/sysadmin-util)

## Tool integrations

- **pnpm** — PATH configured via pnpm installer snippet — [pnpm.io](https://pnpm.io/)
- **Google Cloud SDK** — Auto-loaded if installed — [cloud.google.com/sdk](https://cloud.google.com/sdk)
- **LM Studio CLI** (`lms`) — PATH added for local model inference — [GitHub](https://github.com/lmstudio-ai)
- **rbenv** — Ruby version manager (loaded if available) — [rbenv.github.io](https://github.com/rbenv/rbenv)
- **GRC** — Colorizes unix tools (loaded if available) — [GitHub](https://github.com/garabik/grc)

## Updating existing machine

```bash
cd ~/.dotfiles && git pull && bash install/symlinks.sh --force
```

## Notes

- Node.js/Python shown in prompt **only** inside project directories
- Git repos show full path (not truncated to repo root)
- Backups of old configs saved as `.bak` files on first run
