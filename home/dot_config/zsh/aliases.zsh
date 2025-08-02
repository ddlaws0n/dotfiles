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
alias gst='git status'
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
refresh() {
    source ~/.zshrc
}
# Tree aliases based on available tools
if command -v eza &> /dev/null; then
    alias tr="eza --tree --git-ignore --color=always --group-directories-first"
else
    alias tr="tree -a -C --gitignore"
fi

# New tools from your Brewfile (safe aliases that don't override system commands)
alias tre='tre-command'     # Tree-like find alternative
alias usage='usage'         # Modern top alternative
# Note: bat alias for cat defined above in conditional section

# Additional useful aliases for new tools
alias llm='ollama'
alias act='act --container-architecture linux/amd64'  # GitHub Actions local testing
alias mise-activate='eval "$(mise activate zsh)"'

# Task master
alias tm='task-master'
alias taskmaster='task-master'

# Function for flexibility (takes an optional filename) and fallback editor.
# Usage: scripts [filename_in_scripts_dir]
# If no filename, opens the ~/.scripts directory (or a file named .scripts) with the editor.
scripts() {
    local editor="${VISUAL:-${EDITOR:-vi}}" # Use $VISUAL, then $EDITOR, then vi
    local target_path="$HOME/.scripts"
    if [[ -n "$1" ]]; then
        # If an argument is provided, assume it's a file within ~/.scripts
        target_path="$target_path/$1"
    fi
    command "$editor" "$target_path"
}

alias czconfig="${VISUAL:-${EDITOR:-vi}} $HOME/.config/chezmoi/chezmoi.yaml"
alias dotfiles="cz edit"

# Function to run 'refresh' only if 'cz apply' succeeds and provides feedback.
dotsave() {
    if command chezmoi apply; then
        echo "Chezmoi changes applied. Reloading Zsh..."
        refresh # 'refresh' is assumed to be an alias for 'source ~/.zshrc'
    else
        echo "Error: 'chezmoi apply' failed. Zsh not reloaded." >&2
        return 1 # Indicates failure
    fi
}

# Function to reload Zsh (via 'refresh'), adds feedback,
zshconfig() {
    if command chezmoi edit "$HOME/.config/zsh"; then # Edit Zsh config dir
        echo "Zsh configuration edited. Reloading Zsh..."
        refresh # Reload Zsh using the 'refresh' alias
    else
        echo "Error: Editing Zsh configuration failed or was cancelled. Zsh not reloaded." >&2
        return 1 # Indicates failure
    fi
}

# USEFUL FUNCTIONS (merged from functions.zsh)

# Function to update all plugins and packages
update_all() {
  echo "Updating brew packages..."
  brew update && brew upgrade
  echo "Updating antidote and plugins..."
  antidote update
  echo "Updating mise tools..."
  mise upgrade
  echo "Updating ollama models..."
  ollama list | tail -n +2 | awk '{print $1}' | xargs -I {} ollama pull {}
  echo "Done!"
}

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
