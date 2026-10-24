#!/bin/sh
#
# Dotfiles installer — runs only the steps you name, never all at once.
# Usage: ./install.sh [--force] <step>...
#        ./install.sh                # Ask y/N for each step on this OS
#
# Steps:
#   links       Core config symlinks (any OS)
#   work-links  Workstation symlinks, herdr plugins, g-today agent (macOS)
#   packages    System packages from packages.txt via apt/pacman (Linux)
#   brew        Homebrew + Brewfile (macOS)
#   mas         Mac App Store apps from mac-apps.txt (macOS)
#   macos       macOS defaults (macOS)
#   simple      = links packages
#   work        = links work-links brew mas macos
#
# Existing files and macOS settings you've customized are kept and reported.
# --force replaces them (files are backed up first).
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_PREFIX="  [\033[00;34m..\033[0m ]"
OK_PREFIX="  [\033[00;32mOK\033[0m ]"

info()  { printf "\r${LOG_PREFIX} $1\n"; }
ok()    { printf "\r${OK_PREFIX} $1\n"; }
fail()  { printf "\r  [\033[0;31mFAIL\033[0m] $1\n"; exit 1; }
usage() { sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

OS="$(uname -s)"
need_mac() { [ "$OS" = "Darwin" ] || { info "skipping $1 (macOS only)"; return 1; }; }

# ── Steps ────────────────────────────────────────────────────────────────────

step_links() {
  info "Installing core config symlinks..."
  bash "$SCRIPT_DIR/install/symlinks.sh"
}

step_work_links() {
  need_mac work-links || return 0
  info "Installing workstation config symlinks..."
  bash "$SCRIPT_DIR/install/symlinks-work.sh"
}

step_packages() {
  if command -v apt >/dev/null 2>&1; then
    PKG_CMD="sudo apt install -y"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_CMD="sudo pacman -S --needed --noconfirm"
  else
    info "skipping packages (no apt or pacman)"
    return 0
  fi

  # Read packages, skip comments and empty lines
  PACKAGES=$(grep -v '^\s*#' "$SCRIPT_DIR/packages.txt" | grep -v '^\s*$' | tr '\n' ' ')

  if [ -n "$PACKAGES" ]; then
    info "Installing: $PACKAGES"
    $PKG_CMD $PACKAGES || info "package install had failures (see above)"
  fi
}

step_brew() {
  need_mac brew || return 0
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    bash "$SCRIPT_DIR/install/homebrew.sh"
    # Fresh Apple Silicon installs aren't on PATH until a new shell
    if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  fi

  if brew bundle check --file="$SCRIPT_DIR/Brewfile" >/dev/null 2>&1; then
    ok "Brewfile already satisfied"
  # --no-upgrade: install what's missing, leave versions you already have alone
  elif brew bundle --no-upgrade --file="$SCRIPT_DIR/Brewfile"; then
    ok "Packages installed"
  else
    info "brew bundle had failures (see above) — re-run: brew bundle --no-upgrade --file=$SCRIPT_DIR/Brewfile"
  fi
}

step_mas() {
  need_mac mas || return 0
  command -v mas >/dev/null 2>&1 || { info "skipping mas (not installed — run the brew step first)"; return 0; }
  INSTALLED_MAS=$(mas list 2>/dev/null | awk '{print $1}')
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in '#'*|'') continue ;; esac
    ID=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | cut -d' ' -f2-)
    if echo "$INSTALLED_MAS" | grep -qx "$ID"; then
      info "Already installed: $NAME"
    elif mas install "$ID" >/dev/null 2>&1; then
      ok "Installed: $NAME"
    else
      info "Couldn't install: $NAME — run: mas install $ID"
    fi
  done < "$SCRIPT_DIR/mac-apps.txt"
}

step_macos() {
  need_mac macos || return 0
  info "Applying macOS defaults..."
  bash "$SCRIPT_DIR/install/osx-config.sh"
}

# ── Parse args ───────────────────────────────────────────────────────────────

export FORCE=""
STEPS=""
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    simple)  STEPS="$STEPS links packages" ;;
    work)    STEPS="$STEPS links work-links brew mas macos" ;;
    links|work-links|packages|brew|mas|macos) STEPS="$STEPS $arg" ;;
    *) usage ;;
  esac
done

if [ -z "$STEPS" ]; then
  [ -t 0 ] || usage
  case "$OS" in
    Darwin) CANDIDATES="links work-links brew mas macos" ;;
    *)      CANDIDATES="links packages" ;;
  esac
  for s in $CANDIDATES; do
    printf "  Run step '%s'? [y/N] " "$s"
    read -r ans
    case "$ans" in [yY]*) STEPS="$STEPS $s" ;; esac
  done
fi

[ -n "$FORCE" ] && info "--force: existing files/settings will be replaced"

for s in $STEPS; do
  "step_$(echo "$s" | tr - _)"
done

info "Done! Run 'exec zsh' to start."
