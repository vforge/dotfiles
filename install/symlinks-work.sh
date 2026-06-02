#!/bin/sh
#
# Workstation symlinks (macOS/desktop only)
# Run after install/symlinks.sh
#

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

set -e

info ()    { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; }
success () { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }

link_file () {
  local src=$1 dst=$2
  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    mv "$dst" "${dst}.backup" 2>/dev/null || true
    success "backed up $dst"
  fi
  ln -sf "$1" "$2"
  success "linked $1 to $2"
}

info 'Installing workstation symlinks'

# Hyper terminal config
link_file "$DOTFILES_ROOT/settings/hyper.js.symlink" "$HOME/.config/hyper/hyper.js"

# Vim config
link_file "$DOTFILES_ROOT/settings/vimrc.symlink" "$HOME/.vimrc"

# htop config
mkdir -p "$HOME/.config/htop"
link_file "$DOTFILES_ROOT/settings/htoprc.symlink" "$HOME/.config/htop/htoprc"

# Gem config (Ruby)
link_file "$DOTFILES_ROOT/settings/gemrc.symlink" "$HOME/.gemrc"

# Husky config (Git hooks)
link_file "$DOTFILES_ROOT/settings/huskyrc.symlink" "$HOME/.huskyrc"

echo '  Done!'
