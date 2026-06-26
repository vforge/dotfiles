alias tty-reset='$DOTFILES/system/tty-reset.zsh'

alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

alias g='git'

# Ghostty sets TERM=xterm-ghostty, but many remote machines do not have that
# terminfo entry installed. SSH sends TERM as the pty terminal type, so remote
# ncurses tools (tmux, top, vim, etc.) can fail with:
#   missing or unsuitable terminal: xterm-ghostty
# Use a widely available fallback for interactive ssh sessions. Override with
# SSH_TERM=xterm-ghostty after installing the Ghostty terminfo on the remote.
ssh() {
  TERM="${SSH_TERM:-xterm-256color}" command ssh "$@"
}

alias ka='k -n'
alias k='k -A'

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
else
  alias ls="ls -F --color"
  alias l="ls -lAh --color"
  alias ll="ls -l --color"
  alias la='ls -A --color'
fi
