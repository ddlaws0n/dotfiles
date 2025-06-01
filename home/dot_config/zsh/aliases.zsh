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
refresh() {
    source ~/.zshrc
}
alias tr="tree -a -C --gitignore"

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
