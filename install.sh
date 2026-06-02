#!/bin/sh
#
# Dotfiles installer
# Usage: ./install.sh [simple|work]
#        ./install.sh           # Auto-detect mode
#
# Modes:
#   simple  — Core configs + system packages (Linux servers, headless)
#   work    — Full setup with Homebrew + apps (macOS workstations)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_PREFIX="  [\033[00;34m..\033[0m ]"
OK_PREFIX="  [\033[00;32mOK\033[0m ]"

info()  { printf "\r${LOG_PREFIX} $1\n"; }
ok()    { printf "\r${OK_PREFIX} $1\n"; }
fail()  { printf "\r  [\033[0;31mFAIL\033[0m] $1\n"; exit 1; }

# ── Detect mode ──────────────────────────────────────────────────────────────

MODE="${1:-}"

if [ -z "$MODE" ]; then
  case "$(uname -s)" in
    Darwin) MODE="work" ;;
    Linux)  MODE="simple" ;;
    *)      fail "Unknown OS. Use: ./install.sh simple|work" ;;
  esac
fi

info "Mode: ${MODE}"

# ── Core symlinks (both modes) ───────────────────────────────────────────────

info "Installing core config symlinks..."
bash "$SCRIPT_DIR/install/symlinks.sh" --force
ok "Core configs linked"

# ── Simple mode (Linux) ─────────────────────────────────────────────────────

if [ "$MODE" = "simple" ]; then
  info "Simple mode — installing system packages..."

  # Detect package manager
  if command -v apt >/dev/null 2>&1; then
    PKG_CMD="sudo apt install -y"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_CMD="sudo pacman -S --noconfirm"
  else
    fail "No supported package manager found (apt or pacman)"
  fi

  # Read packages, skip comments and empty lines
  PACKAGES=$(grep -v '^\s*#' "$SCRIPT_DIR/packages.txt" | grep -v '^\s*$' | tr '\n' ' ')

  if [ -n "$PACKAGES" ]; then
    info "Installing: $PACKAGES"
    $PKG_CMD $PACKAGES || ok "Package install complete (some may already be installed)"
  fi

  info "Done! Run 'exec zsh' to start."
  exit 0
fi

# ── Workstation mode (macOS) ─────────────────────────────────────────────────

if [ "$MODE" != "work" ]; then
  fail "Unknown mode: $MODE. Use: simple or work"
fi

# Workstation extras symlinks
info "Installing workstation config symlinks..."
bash "$SCRIPT_DIR/install/symlinks-work.sh" --force
ok "Workstation configs linked"

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  bash "$SCRIPT_DIR/install/homebrew.sh"
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# Brewfile (CLI tools + casks)
info "Installing packages via brew bundle..."
brew bundle --file="$SCRIPT_DIR/Brewfile" || ok "Brew bundle complete"
ok "Packages installed"

# Mac App Store apps
if [ -f "$SCRIPT_DIR/mac-apps.txt" ] && command -v mas >/dev/null 2>&1; then
  info "Installing Mac App Store apps..."
  while IFS= read -r line || [ -n "$line" ]; do
    ID=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | cut -d' ' -f2-)
    mas install "$ID" >/dev/null 2>&1 && ok "Installed: $NAME" || info "Already installed/skipped: $NAME"
  done < "$SCRIPT_DIR/mac-apps.txt"
fi

# macOS defaults
info "Applying macOS defaults..."
bash "$SCRIPT_DIR/install/osx-config.sh"
ok "macOS defaults applied"

info "Done! Run 'exec zsh' to start."
