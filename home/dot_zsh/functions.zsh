# Function to update all plugins and packages
update_all() {
  echo "Updating brew packages..."
  brew update && brew upgrade
  echo "Updating zinit and plugins..."
  zinit self-update
  zinit update --all
  echo "Done!"
}

# Add your other functions here
