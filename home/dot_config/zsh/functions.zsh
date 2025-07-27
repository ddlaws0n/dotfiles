# Function to update all plugins and packages
update_all() {
  echo "Updating brew packages..."
  brew update && brew upgrade
  echo "Updating zinit and plugins..."
  zinit self-update
  zinit update --all
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
