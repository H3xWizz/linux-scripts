#!/bin/zsh

# Clear the screen and display the header
clear
cat << "EOF"
 _   _ _____    __        ___             ____            _       _       
| | | |___ /_  _\ \      / (_)________   / ___|  ___ _ __(_)_ __ | |_ ___ 
| |_| | |_ \ \/ /\ \ /\ / /| |_  /_  /   \___ \ / __| '__| | '_ \| __/ __|
|  _  |___) >  <  \ V  V / | |/ / / /     ___) | (__| |  | | |_) | |_\__ \
|_| |_|____/_/\_\  \_/\_/  |_/___/___|   |____/ \___|_|  |_| .__/ \__|___/
                                                         |_|            

Dev Setup Script...
EOF

# Update package list and fully upgrade the system
sudo apt update
sudo apt full-upgrade -y

# Install required packages
sudo apt install curl wget zsh git jq -y

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi

# Switch to Zsh shell
exec zsh

# Install NVM (Node Version Manager)
latest_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')

# Print the latest version
echo "Latest NVM version: $latest_version"

# Install or update NVM
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$latest_version/install.sh | zsh
else
    echo "NVM is already installed. Updating..."
    cd "$HOME/.nvm" && git fetch --tags && git checkout $latest_version && cd -
fi

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Install Node.js and use the latest LTS version
nvm install --lts
nvm use --lts

# Install pnpm globally using npm
npm install -g pnpm

# Configure pnpm
pnpm setup

# Add pnpm configuration to .zshrc
echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.zshrc
echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc

# Install vercel-cli using pnpm
pnpm install -g vercel@latest

# Log into Vercel account and display account information
vercel login
vercel whoami

# Set Zsh as the default shell
chsh -s $(which zsh)

# Download and run JetBrains Toolbox installation script
mkdir -p ~/tmp
cd ~/tmp
curl -o- https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/refs/heads/master/jetbrains-toolbox.sh | zsh

# Clean up temporary files
rm -rf ~/tmp

# Remind the user to reload Zsh configuration
echo "Don't forget to use 'source ~/.zshrc' to reload your Zsh configuration."

# Set up GitHub global configuration
echo "Please type your GitHub name:"
read ghName
echo "Please type your GitHub email:"
read ghMail

echo "Setting up GitHub global user as: $ghName <$ghMail>"
git config --global user.name "$ghName"
git config --global user.email "$ghMail"

# Ask the user if they want to restart the system
echo "Do you want to restart the system now? (yes/no)"
read restartAnswer

# Convert the answer to lowercase for case-insensitive comparison
answer=$(echo "$restartAnswer" | tr '[:upper:]' '[:lower:]')

# Check the user's response
if [[ "$answer" == "yes" || "$answer" == "y" ]]; then
    sudo reboot
elif [[ "$answer" == "no" || "$answer" == "n" ]]; then
    echo "Setup complete. You chose not to restart."
    exit 0
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi
