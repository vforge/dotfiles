export PATH=./bin:$HOME/bin:$HOME/.yarn/bin:/usr/local/bin:/usr/local/sbin:$HOME/.config/yarn/global/node_modules/.bin:$DOTFILES/bin:~/Library/Python/2.7/bin:~/.local/bin:$PATH
export MANPATH=/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH

# brew overrides
if command -v brew >/dev/null 2>&1; then
  export PATH="$(brew --prefix)/bin:$PATH"
fi
