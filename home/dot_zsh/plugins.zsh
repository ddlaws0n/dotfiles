# Initialize zinit
source $HOMEBREW_PREFIX/opt/zinit/zinit.zsh

# Load plugins with lazy loading for better startup time
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit light sharkdp/bat


zinit ice wait lucid
zinit snippet OMZ::plugins/git/git.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/terraform/terraform.plugin.zsh

# fzf-tab configuration
zstyle ':completion:*' fzf-tab true
zstyle ':completion:*' fzf-tab-bin-paths "$HOMEBREW_PREFIX/bin"
zstyle ':completion:*' fzf-tab-bin-paths "$HOMEBREW_PREFIX/sbin"
zstyle ':completion:*' fzf-tab-bin-paths "$HOMEBREW_PREFIX/opt/fzf/bin"
zstyle ':completion:*' fzf-tab-bin-paths "$HOMEBREW_PREFIX/opt/fzf/sbin"

# fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Make autosuggestions more visible
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=60"
