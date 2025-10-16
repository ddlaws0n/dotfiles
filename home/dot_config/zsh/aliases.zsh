# Better defaults - use eza instead of ls when available

if command -v eza &> /dev/null; then
    alias ls='eza --color=always --group-directories-first --git-ignore --sort name'
    alias ll='eza -lh --color=always --group-directories-first'
    alias la='eza -lah --color=always --group-directories-first'
    alias lt='eza --tree --color=always --group-directories-first'
    alias tree='eza --tree --color=always --group-directories-first'
else
    alias ls='ls -G'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

command -v bat &>/dev/null && alias cat='bat --style=auto'
command -v rg &>/dev/null && alias grep='rg'
command -v fd &>/dev/null && alias find='fd'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# System
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %T"'
alias myip='curl -s https://ipinfo.io/ip'

# Misc
alias h='history'
alias reload='exec zsh'

# Chezmoi
if command -v chezmoi &>/dev/null; then
alias cz='chezmoi'
alias cza='chezmoi apply'
alias czd='chezmoi diff'
alias cze='chezmoi edit --apply'
alias czu='chezmoi update'
alias czcd='cd $(chezmoi source-path) && code .'
fi

# Mise
if command -v mise &>/dev/null; then
  alias m='mise'
  alias mt='mise task'
  alias mtr='mise task run'
  alias mu='mise use'
  alias mup='mise update'
  alias ma='mise activate'
  alias ms='mise status'
  alias mi='mise install'
  alias mrm='mise remove'
fi

# Docker (if installed)
if command -v docker &>/dev/null; then
  alias d='docker'
  alias dc='docker compose'
  alias dps='docker ps'
fi
