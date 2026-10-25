# GRC colorizes nifty unix tools all over the place
if (( $+commands[grc] )) && (( $+commands[brew] )); then
  grc_init="$(brew --prefix)/etc/grc.bashrc"
  [[ -f "$grc_init" ]] && source "$grc_init"
fi

# init rbenv
if (( $+commands[rbenv] ))
then
  eval "$(rbenv init -)"
fi
