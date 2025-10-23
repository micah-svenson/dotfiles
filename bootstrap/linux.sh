#!/bin/bash
set -euo pipefail

# Linux/Ubuntu Bootstrap Script
echo "🐧 Starting Linux bootstrap..."

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install essential development tools
echo "🔧 Installing development tools..."
sudo apt install -y \
    git \
    curl \
    wget \
    zsh \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    tree \
    htop \
    unzip

# Install ripgrep
echo "📦 Installing ripgrep..."
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb
rm ripgrep_13.0.0_amd64.deb

# Install fzf
echo "🔍 Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Install git-delta
echo "📦 Installing git-delta..."
curl -LO https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
sudo dpkg -i git-delta_0.16.5_amd64.deb
rm git-delta_0.16.5_amd64.deb

# Install neovim
echo "📝 Installing Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz

# Install chezmoi
echo "🏠 Installing chezmoi..."
sh -c "$(curl -fsLS get.chezmoi.io)"

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Install VS Code
echo "💻 Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

echo "✅ Linux bootstrap complete!"
echo "🔄 Please restart your terminal and run 'chezmoi apply' to configure dotfiles."