autoload -U add-zsh-hook

# Initialize nvm for every interactive shell so globally installed Node CLIs
# (like `pi`) are available in fresh terminals.
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh" --no-use
fi

# Ensure the default Node version is active unless the current shell already
# has an nvm-managed version selected.
if command -v nvm >/dev/null 2>&1; then
  local_nvm_current="$(nvm current 2>/dev/null)"
  if [ "$local_nvm_current" = "none" ] || [ "$local_nvm_current" = "system" ]; then
    nvm use default --silent >/dev/null 2>&1 || true
  fi
fi

load-nvmrc() {
  command -v nvm >/dev/null 2>&1 || return

  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm current)" ]; then
      nvm use >/dev/null
    fi
  elif [ "$(nvm current)" != "$(nvm version default)" ]; then
    nvm use default --silent >/dev/null 2>&1 || true
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
