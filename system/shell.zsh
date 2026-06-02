# zinit - modern zsh plugin manager
# https://github.com/zdharma-continuum/zinit
ZINIT_HOME="$HOME/.local/share/zinit"
if [[ ! -f "$ZINIT_HOME/zinit.git/zinit.zsh" ]]; then
  mkdir -p "$ZINIT_HOME"
  curl -fsSL "https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh" | zsh
fi
source "$ZINIT_HOME/zinit.git/zinit.zsh"

# Core plugins
# Keep completion simple and synchronous: stock compinit + extra completion defs.
zinit light "zsh-users/zsh-completions"
autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Safer alternatives to zsh-autocomplete
zinit light "zsh-users/zsh-autosuggestions"
zinit light "zsh-users/zsh-history-substring-search"
zinit light "djui/alias-tips"

# Keep Tab for normal completion; accept inline suggestions with Ctrl-Space,
# Right Arrow, or End (the latter two are handled by zsh-autosuggestions).
bindkey '^I' expand-or-complete
bindkey '^ ' autosuggest-accept

# Bind Up/Down to history substring search when available
bindkey "${terminfo[kcuu1]:-^[[A}" history-substring-search-up
bindkey "${terminfo[kcud1]:-^[[B}" history-substring-search-down

# Syntax highlighting (loaded last for correct priority)
zinit light "zsh-users/zsh-syntax-highlighting"

# Directory jumping is provided by zoxide in ~/.dotfiles/system/cd.zsh
# Keep rupa/z disabled so it does not override the `z` command.
# zinit light "rupa/z"

# Navigation & productivity
zinit light "supercrabtree/k"  # search git log by keyword
zinit light "peterhurford/git-it-on.zsh"
zinit light "skx/sysadmin-util"



# Starship prompt (replaces pure)
eval "$(starship init zsh)"
