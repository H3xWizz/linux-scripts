#!/bin/bash

# Update package list and fully upgrade the system
sudo apt update
sudo apt full-upgrade -y

# Install required packages
sudo apt install curl wget zsh git -y

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

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
source ~/.zshrc | zsh

# Install the latest LTS version of Node.js
nvm install --lts # At this moment (when i write script) Latest LTS in nvm is v20.15.0
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

# Installing vercel-cli
pnpm i -g vercel@latest

# Connect to vercel account 
vercel login
vercel whoami

# Set Zsh as the default shell
chsh -s $(which zsh)

# Create tmp directory and download JetBrains Toolbox
mkdir -p ~/tmp
cd ~/tmp
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.4.0.32175.tar.gz

# Extract and run JetBrains Toolbox
tar -xvf jetbrains-toolbox-2.4.0.32175.tar.gz
sudo chmod +x jetbrains-toolbox-2.4.0.32175/jetbrains-toolbox
./jetbrains-toolbox-2.4.0.32175/jetbrains-toolbox

# Remove tmp directory
rm ~/tmp -Rf

#Setting up Github config globals
echo "Please type your github name:"
read ghName
echo "Please type your github mail:"
read ghMail

echo "Setting up gh globals user as: $ghName <$ghMail>"
git config --global user.name "$ghName"
git config --global user.mail "$ghMail"

echo "Do you want restart system now? (yes/no)"
read restartAnswer

# Convert answer to lowercase for case-insensitive comparison
answer=$(echo "$restartAnswer" | tr '[:upper:]' '[:lower:]')

# Check user's response
if [[ "$RestartAnswer" == "yes" || "$restartAnswer" == "y" ]]; then
    sudo reboot
    # Place your script commands here
elif [[ "$answer" == "no" || "$answer" == "n" ]]; then
    echo "Stopping the script."
    exit 0
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi
