# Extract archives
extract() {
  [[ -z "$1" || ! -f "$1" ]] && { echo "Usage: extract <file>"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz|*.txz)   tar xJf "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.rar)            unrar x "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip)            unzip "$1" ;;
    *.7z)             7z x "$1" ;;
    *)                echo "Unsupported: $1" ;;
  esac
}

# Make dir and cd
mkcd() { mkdir -p "$1" && cd "$1"; }

# Print contents of directory when entering (but not during shell startup)
cd() {
    builtin cd "$@" || return 1
    [[ -n "$PS1" && -z "$_SHELL_STARTING" ]] && la
}

# Find file
ff() { command -v fd &>/dev/null && fd "$@" || find . -type f -iname "*$1*"; }

# FZF edit
fe() {
  command -v fzf &>/dev/null || { echo "fzf required"; return 1; }
  local file=$(fzf --query="$1" --select-1 --exit-0)
  [[ -n "$file" ]] && ${EDITOR:-nano} "$file"
}

# FZF cd
fcd() {
  command -v fzf &>/dev/null || { echo "fzf required"; return 1; }
  local dir=$(fd --type d 2>/dev/null | fzf --query="$1" --select-1 --exit-0)
  [[ -n "$dir" ]] && cd "$dir"
}

# Update all
update_all() {
  echo "🔄 Updating Homebrew..."; brew update && brew upgrade && brew cleanup
  echo "🔄 Updating mise..."; mise self-update && mise upgrade
  echo "🔄 Updating Zinit..."; zinit self-update && zinit update --all
  echo "✅ Done!"
}
