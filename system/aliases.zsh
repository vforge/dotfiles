alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

alias g='git'

alias -g atombeta="ATOM_HOME=~/.atombeta open -a 'Atom Beta'"

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
