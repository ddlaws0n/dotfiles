# Useful aliases
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# My aliases
alias brew='$HOMEBREW_PREFIX/bin/brew'
alias cz="chezmoi"
alias czconfig="$EDITOR ~/.config/chezmoi/chezmoi.toml"
alias refresh="source ~/.zshrc"

alias dotfiles="cz edit"
alias dotsave="cz apply && refresh"

# Wiz
alias wizcli="~/wizcli"