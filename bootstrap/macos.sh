#!/bin/bash
set -euo pipefail

# macOS Bootstrap Script
echo "🍎 Starting macOS bootstrap..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install essential development tools
echo "🔧 Installing development tools..."
brew install --formula \
    git \
    chezmoi \
    ripgrep \
    fzf \
    git-delta \
    neovim \
    zsh \
    curl \
    wget \
    jq \
    tree \
    htop

# Install GUI applications
echo "🖥️  Installing GUI applications..."
brew install --cask \
    iterm2 \
    visual-studio-code \
    cursor \
    obsidian \
    bitwarden \
    karabiner-elements \
    chrome-browser \
    arc \
    openscad@snapshot

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

echo "✅ macOS bootstrap complete!"
echo "🔄 Please restart your terminal and run 'chezmoi apply' to configure dotfiles."