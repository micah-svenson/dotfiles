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
RG_DEB_URL=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url')
curl -L "$RG_DEB_URL" -o "$TEMP_DIR/ripgrep.deb"
sudo dpkg -i "$TEMP_DIR/ripgrep.deb"

# Install fzf (binary only — shell integration is managed by chezmoi in .zshrc)
echo "🔍 Installing fzf..."
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --bin

# Install git-delta (latest version)
echo "📦 Installing git-delta..."
DELTA_DEB_URL=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.assets[] | select(.name | test("^git-delta_.*_amd64\\.deb$")) | .browser_download_url')
curl -L "$DELTA_DEB_URL" -o "$TEMP_DIR/git-delta.deb"
sudo dpkg -i "$TEMP_DIR/git-delta.deb"

# Install neovim (latest version)
echo "📝 Installing Neovim..."
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o "$TEMP_DIR/nvim-linux-x86_64.tar.gz"
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "$TEMP_DIR/nvim-linux-x86_64.tar.gz"
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

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
