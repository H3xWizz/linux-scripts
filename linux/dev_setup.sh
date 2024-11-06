#!/bin/bash

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

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install NVM
latest_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')

# Print the latest version
echo "Latest NVM version: $latest_version"

# Download the installation script for the latest version of NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$latest_version/install.sh | bash

# Add NVM configuration to .bashrc and .zshrc
echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc

# Add pnpm alias to .bashrc and .zshrc
echo 'alias pn=pnpm' >> ~/.bashrc
echo 'alias pn=pnpm' >> ~/.zshrc

# Reload shell configuration
source ~/.bashrc

# Install the latest LTS version of Node.js
nvm install --lts
nvm use --lts

# Install pnpm
npm i -g pnpm

# Configure pnpm for global packages
pnpm setup

# Add pnpm configuration to .bashrc and .zshrc
echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.zshrc
echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.zshrc

# Reload shell configuration again
source ~/.bashrc
source ~/.zshrc

# Install vercel-cli
pnpm i -g vercel@latest

# Connect to vercel account
vercel login
vercel whoami

# Set Zsh as the default shell
chsh -s $(which zsh)

# Create tmp directory and download JetBrains Toolbox
mkdir -p ~/tmp
cd ~/tmp

curl -o- https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/refs/heads/master/jetbrains-toolbox.sh | bash

# Remove tmp directory
rm -rf ~/tmp

echo "Don't forget to use 'source ~/.zshrc' to reload your Zsh configuration."

# Set up GitHub config globals
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
    echo "Stopping the script."
    exit 0
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi
