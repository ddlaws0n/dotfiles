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
alias refresh="source ~/.zshrc"

alias tr="tree -a -C --gitignore"

alias czconfig="$VISUAL ~/.config/chezmoi/chezmoi.yaml"
alias dotfiles="cz edit"
alias dotsave="cz apply && refresh"
alias alias="cz edit ~/.zsh/aliases.zsh"

# Wiz
alias wizcli="~/wizcli"