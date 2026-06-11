autoload -Uz add-zsh-hook

_tmux_set_title() {
  [[ -z "$TMUX" ]] && return
  printf '\033]2;%s\033\\' "$1"
}

_tmux_title_precmd() {
  local prefix=""
  [[ -n "$SSH_CONNECTION" ]] && prefix="[ssh:${HOST%%.*}] "
  _tmux_set_title "${prefix}${ZSH_NAME:-zsh}:${PWD}"
}

_tmux_title_preexec() {
  local prefix=""
  [[ -n "$SSH_CONNECTION" ]] && prefix="[ssh:${HOST%%.*}] "
  _tmux_set_title "${prefix}${ZSH_NAME:-zsh}:$1"
}

add-zsh-hook precmd  _tmux_title_precmd
add-zsh-hook preexec _tmux_title_preexec
