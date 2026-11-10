#!/bin/sh
#
# Herdr config, plugins, and supporting memex config (macOS/Linux)
# Run with: bash install.sh herdr
#

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

set -e

info ()    { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; }
success () { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }

link_file () {
  local src=$1 dst=$2
  if [ "$(readlink "$dst")" = "$src" ]; then
    info "already linked $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -z "$FORCE" ]; then
      info "kept existing $dst (install.sh --force to replace it)"
      return
    fi
    # Never overwrite an earlier backup — that's the only copy of the original
    local bak="${dst}.backup"
    if [ -e "$bak" ] || [ -L "$bak" ]; then bak="${dst}.backup.$(date +%Y%m%d%H%M%S)"; fi
    mv "$dst" "$bak"
    success "backed up $dst to $bak"
  fi
  ln -s "$src" "$dst"
  success "linked $src to $dst"
}

info 'Installing Herdr config and plugins'

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
  # Claude skill for driving herdr panes/agents; regenerated so it matches the installed version
  mkdir -p "$HOME/.claude/skills/herdr"
  herdr --skill > "$HOME/.claude/skills/herdr/SKILL.md" && success "wrote herdr Claude skill"
else
  info "herdr not found — config linked; install Herdr and re-run: bash install.sh herdr"
fi

# herdr plugin settings — "<plugin id>:<file in settings/>"
for pair in hhdebb.herdr-radar:herdr-radar persiyanov.reviewr:herdr-reviewr worktrunk:herdr-worktrunk; do
  dir="$HOME/.config/herdr/plugins/config/${pair%%:*}"
  mkdir -p "$dir"
  link_file "$DOTFILES_ROOT/settings/${pair#*:}.toml.symlink" "$dir/config.toml"
done
link_file "$DOTFILES_ROOT/settings/herdr-radar-render.cjs" "$HOME/.config/herdr/plugins/config/hhdebb.herdr-radar/render.cjs"

# memex (transcript search used by the memex herdr plugin)
mkdir -p "$HOME/.memex"
link_file "$DOTFILES_ROOT/settings/memex.toml.symlink" "$HOME/.memex/config.toml"
if [ "$(uname -s)" = "Darwin" ] && command -v memex >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  brew services start memex >/dev/null 2>&1 || true
fi

echo '  Done!'
