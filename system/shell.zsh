# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

# Essential
source ~/.zplug/init.zsh

# Make sure to use double quotes to prevent shell expansion
zplug "zsh-users/zsh-syntax-highlighting"
zplug "chrissicool/zsh-256color", from:github

zplug "djui/alias-tips", from:github
zplug "unixorn/git-extra-commands", from:github
zplug "supercrabtree/k"
zplug "unixorn/warhol.plugin.zsh"
zplug "peterhurford/git-it-on.zsh", from:github
zplug "skx/sysadmin-util"
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

zplug "RobSis/zsh-completion-generator"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"

# theme
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# zplug denysdovhan/spaceship-zsh-theme, use:spaceship.zsh, from:github, as:theme


# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

zplug load
