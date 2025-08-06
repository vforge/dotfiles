# replaced by zoxide
# cdpath=(.
#   ~
#   ~/Dropbox/Development/vforge
#   ~/Dropbox/Development
#   ~/Software
#   ~/Developer
#   ~/Developer/wikia
#   ~/Developer/vforge
#   ~/Code
#   ~/Work
#   /usr/wikia
#   /usr/wikia/slot1/current
#   /usr/wikia/source)

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
