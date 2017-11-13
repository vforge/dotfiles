# GRC colorizes nifty unix tools all over the place
if (( $+commands[grc] )) && (( $+commands[brew] ))
then
  source `brew --prefix`/etc/grc.bashrc
fi

# init rbenv
if (( $+commands[rbenv] ))
then
  eval "$(rbenv init -)"
fi

# Check if nvm is installed
if [[ ! -d /usr/local/opt/nvm/nvm.sh ]]; then
  source /usr/local/opt/nvm/nvm.sh
fi
