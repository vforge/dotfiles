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

# herdr config (only config.toml — the dir also holds sockets/logs/session state)
mkdir -p "$HOME/.config/herdr"
# herdr-radar writes absolute paths into it; .gitattributes runs this filter to commit $HOME instead
git -C "$DOTFILES_ROOT" config filter.homepath.clean 'sed "s#$HOME#\$HOME#g"'
link_file "$DOTFILES_ROOT/settings/herdr.toml.symlink" "$HOME/.config/herdr/config.toml"

# herdr plugins (already-installed ones are skipped)
if command -v herdr >/dev/null 2>&1; then
  installed=$(herdr plugin list 2>/dev/null || true)
  grep -v '^#' "$DOTFILES_ROOT/settings/herdr-plugins.txt" | while read -r repo; do
    [ -n "$repo" ] || continue
    if echo "$installed" | grep -q "github:$repo@"; then
      info "herdr plugin $repo already installed"
    elif herdr plugin install -y "$repo" >/dev/null 2>&1; then
      success "installed herdr plugin $repo"
    else
      info "couldn't install herdr plugin $repo — run: herdr plugin install $repo"
    fi
  done
fi

# herdr plugin settings — "<plugin id>:<file in settings/>"
for pair in hhdebb.herdr-radar:herdr-radar persiyanov.reviewr:herdr-reviewr worktrunk:herdr-worktrunk; do
  dir="$HOME/.config/herdr/plugins/config/${pair%%:*}"
  mkdir -p "$dir"
  link_file "$DOTFILES_ROOT/settings/${pair#*:}.toml.symlink" "$dir/config.toml"
done

# memex (transcript search used by the memex herdr plugin)
mkdir -p "$HOME/.memex"
link_file "$DOTFILES_ROOT/settings/memex.toml.symlink" "$HOME/.memex/config.toml"
command -v memex >/dev/null 2>&1 && brew services start memex >/dev/null 2>&1 || true

# Gem config (Ruby)
link_file "$DOTFILES_ROOT/settings/gemrc.symlink" "$HOME/.gemrc"

# Husky config (Git hooks)
link_file "$DOTFILES_ROOT/settings/huskyrc.symlink" "$HOME/.huskyrc"

echo '  Done!'
