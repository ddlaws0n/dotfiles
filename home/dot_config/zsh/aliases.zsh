# Better defaults
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=always'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias kill='kill -9'
alias rm='rm -i'
alias rmd='rm -rf'
alias ax='chmod a+x'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias ~="cd ~"
cd() {
    # Always print contents of directory when entering
    builtin cd "$@" || return 1
    ll
}

# Git
alias gl='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short' # A nicer Git Log

applyignore() {
    # DESC: Applies changes to the git .ignorefile after the files mentioned were already committed to the repo

    git ls-files -ci --exclude-standard -z | xargs -0 git rm --cached
}

# Prefer `bat` over `cat` when installed
[[ "$(command -v bat)" ]] \
    && alias cat="bat"

# MacOS specific
alias cpwd='pwd | tr -d "\n" | pbcopy'
alias cl="fc -e -|pbcopy"
alias cleanDS="find . -type f -name '*.DS_Store' -ls -delete"

# My aliases
alias brew='$HOMEBREW_PREFIX/bin/brew'
alias cz="chezmoi"
alias refresh="source ~/.zshrc"

alias tr="tree -a -C --gitignore"

alias czconfig="$VISUAL ~/.config/chezmoi/chezmoi.yaml"
alias dotfiles="cz edit"
alias dotsave="cz apply && refresh"
alias zshconfig="cz edit ~/.config/zsh"

# Wiz
alias wizcli="~/wizcli"

# AI
alias tm="task-master"

# Functions
buf() {
    # buf: Backup file with time stamp
    local filename
    local filetime

    filename="${1}"
    filetime=$(date +%Y%m%d_%H%M%S)
    cp -a "${filename}" "${filename}_${filetime}"
}
