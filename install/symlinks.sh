#!/bin/sh
#
# Core symlinks (both simple and workstation modes)
# Links essential config files to ~/.
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

info 'Installing core symlinks'

# Shell config
link_file "$DOTFILES_ROOT/system/zshrc.symlink" "$HOME/.zshrc"

# Git config
link_file "$DOTFILES_ROOT/settings/gitconfig.symlink" "$HOME/.gitconfig"
link_file "$DOTFILES_ROOT/settings/gitignore-global.symlink" "$HOME/.gitignore-global"

# Starship prompt config
link_file "$DOTFILES_ROOT/settings/starship.toml.symlink" "$HOME/.starship.toml"

# Tmux config
link_file "$DOTFILES_ROOT/settings/tmux.conf.symlink" "$HOME/.tmux.conf"

# Shell profile (login shells)
link_file "$DOTFILES_ROOT/settings/zprofile.symlink" "$HOME/.zprofile"

# SSH config — only scaffold a default if none exists (preserve local host entries)
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$DOTFILES_ROOT/settings/ssh_config.symlink" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  success "created $HOME/.ssh/config from template"
else
  info "skipping ~/.ssh/config (already exists)"
fi

# Nuxt
link_file "$DOTFILES_ROOT/settings/nuxtrc.symlink" "$HOME/.nuxtrc"

echo '  Done!'
