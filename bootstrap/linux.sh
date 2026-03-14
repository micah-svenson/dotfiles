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

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Install ripgrep (latest version)
echo "📦 Installing ripgrep..."
RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb" -o "$TEMP_DIR/ripgrep.deb"
sudo dpkg -i "$TEMP_DIR/ripgrep.deb"

# Install fzf
echo "🔍 Installing fzf..."
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
else
  echo "fzf already installed, skipping..."
fi

# Install git-delta (latest version)
echo "📦 Installing git-delta..."
DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -o "$TEMP_DIR/git-delta.deb"
sudo dpkg -i "$TEMP_DIR/git-delta.deb"

# Install neovim (latest version)
echo "📝 Installing Neovim..."
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -o "$TEMP_DIR/nvim-linux64.tar.gz"
sudo rm -rf /opt/nvim-linux64
sudo tar -C /opt -xzf "$TEMP_DIR/nvim-linux64.tar.gz"
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

# Install chezmoi
echo "🏠 Installing chezmoi..."
sh -c "$(curl -fsLS get.chezmoi.io/getlb)"

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

# Install nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
  echo "📦 Installing nvm..."
  NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
else
  echo "nvm already installed, skipping..."
fi

# Install lazygit (latest version)
echo "📦 Installing lazygit..."
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz" -o "$TEMP_DIR/lazygit.tar.gz"
tar -C "$TEMP_DIR" -xzf "$TEMP_DIR/lazygit.tar.gz" lazygit
sudo install "$TEMP_DIR/lazygit" /usr/local/bin

echo "✅ Linux bootstrap complete!"
echo "🔄 Please restart your terminal and run 'chezmoi apply' to configure dotfiles."
