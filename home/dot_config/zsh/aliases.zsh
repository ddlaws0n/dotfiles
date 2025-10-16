# Better defaults - use eza instead of ls when available
if command -v eza &> /dev/null; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -lh --color=always --group-directories-first'
    alias la='eza -lah --color=always --group-directories-first'
    alias lt='eza --tree --color=always --group-directories-first'
    alias tree='eza --tree --color=always --group-directories-first'
else
    alias ls='ls -G'
    alias ll='ls -lh'
    alias la='ls -lah'
fi


alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
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
    # Print contents of directory when entering (but not during shell startup)
    builtin cd "$@" || return 1
    # Only show directory contents for interactive cd commands (not during startup)
    [[ -n "$PS1" && -z "$_SHELL_STARTING" ]] && ll
}

# Git - Essential aliases (replaces Oh-My-Zsh git plugin to avoid gh alias conflict)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short' # A nicer Git Log
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git remote'
alias grv='git remote -v'
applyignore() {
    # DESC: Applies changes to the git .ignorefile after the files mentioned were already committed to the repo

    git ls-files -ci --exclude-standard -z | xargs -0 git rm --cached
}

# Prefer `bat` over `cat` when installed
[[ "$(command -v bat)" ]] \
    && alias cat="bat --style=auto"

# MacOS specific
alias cpwd='pwd | tr -d "\n" | pbcopy'
alias cl="fc -e -|pbcopy"
alias cleanDS="find . -type f -name '*.DS_Store' -ls -delete"

# My aliases
alias brew='$HOMEBREW_PREFIX/bin/brew'
alias cz="chezmoi"
alias refresh='source ~/.zshrc'

# New tools from your Brewfile
alias tre='tre-command'     # Tree-like find alternative
alias act='act --container-architecture linux/amd64'  # GitHub Actions local testing

# Task master
alias tm='task-master'
alias taskmaster='task-master'

# Open scripts directory or specific script file
scripts() { $EDITOR "${1:+$HOME/.scripts/$1}${1:-$HOME/.scripts}"; }

czconfig() { $EDITOR "$HOME/.config/chezmoi/chezmoi.yaml"; }
alias dotfiles="cz edit"

# Chezmoi workflow shortcuts
alias dotsave='chezmoi apply && source ~/.zshrc'
alias zshconfig='chezmoi edit ~/.config/zsh'

# 1PASSWORD SECRET MANAGEMENT
# Secure command execution with secrets loaded from 1Password
alias runwithsecrets='op run --env-file="$HOME/.local/share/secrets/secrets.env" --'

# GitHub Actions & Claude Code setup
alias setup-cc='op run --env-file="$HOME/.local/share/secrets/secrets.env" -- setup-cc'

# Helper function to run commands with specific secret categories
runwithwork() {
    if [[ ! -f "$HOME/.local/share/secrets/secrets-work.env" ]]; then
        echo "Work secrets file not found. Using main secrets file." >&2
        runwithsecrets "$@"
    else
        op run --env-file="$HOME/.local/share/secrets/secrets-work.env" -- "$@"
    fi
}

# Validate secrets are accessible
checksecrets() {
    command -v op >/dev/null || { echo "❌ op not installed"; return 1; }
    op account get &>/dev/null || { echo "❌ Not authenticated. Run: op signin"; return 1; }
    [[ -f "$HOME/.local/share/secrets/secrets.env" ]] || { echo "❌ secrets.env missing"; return 1; }
    echo "✅ All checks passed. Usage: runwithsecrets <command>"
}

# USEFUL FUNCTIONS (merged from functions.zsh)

# Update all tools (uses mise task for tool management)
alias updates='brew update && brew upgrade && zinit self-update && zinit update --parallel && mise run update'

# Quick development server with Python
serve() {
  local port=${1:-8000}
  python3 -m http.server $port
}

# Extract any archive
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) unrar e $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xf $1 ;;
      *.tbz2) tar xjf $1 ;;
      *.tgz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick project setup with git
mkproject() {
  local name=$1
  if [ -z "$name" ]; then
    echo "Usage: mkproject <project-name>"
    return 1
  fi

  mkdir "$name" && cd "$name"
  git init
  echo "# $name" > README.md
  echo "node_modules/\n.env\n.DS_Store" > .gitignore
  git add .
  git commit -m "Initial commit"
  echo "Project '$name' created and initialized with git"
}

# Ollama chat shortcut
chat() {
  local model=${1:-llama3.2}
  ollama run $model
}
