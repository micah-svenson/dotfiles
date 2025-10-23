# Dotfiles

A chezmoi-managed dotfiles repository for cross-platform development environment setup (macOS and Linux).

## Quick Start

### New Machine Setup

1. **Run bootstrap script** (installs essential tools including chezmoi):
   ```bash
   # macOS
   curl -fsSL https://raw.githubusercontent.com/micah-svenson/dotfiles/main/bootstrap/macos.sh | bash
   
   # Linux/Ubuntu  
   curl -fsSL https://raw.githubusercontent.com/micah-svenson/dotfiles/main/bootstrap/linux.sh | bash
   ```

2. **Initialize dotfiles**:
   ```bash
   chezmoi init --apply https://github.com/micah-svenson/dotfiles.git
   ```

3. **Restart your shell** to load new configurations.

## What's Included

- **Shell**: Zsh with oh-my-zsh, custom aliases, and cross-platform configurations
- **Editor**: Neovim config (auto-cloned from separate repo) with Lazy.nvim
- **VS Code/Cursor**: Shared settings, keybindings, and extensions
- **Development Tools**: ripgrep, fzf, git-delta, language servers, and more
- **Platform Detection**: Different configs/tools for macOS vs Linux

## Daily Usage

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Update from repository
chezmoi update
```

## Manual Tool Installation

If you need to install tools separately:

```bash
# Install development tools
./scripts/install-tools.sh

# Setup Neovim configuration  
./scripts/setup-nvim.sh
```

## Repository Structure

- `bootstrap/` - Initial machine setup scripts
- `scripts/` - Utility scripts for tool installation
- `dot_*` - Dotfiles managed by chezmoi
- `Library/` - macOS application configurations
- `run_once_*` - Scripts that run once during chezmoi apply

## Customization

The repository uses chezmoi templates for cross-platform compatibility. Key variables:
- `{{ .is_macos }}` / `{{ .is_linux }}` - OS detection
- `{{ .package_manager }}` - "brew" or "apt"

See [CLAUDE.md](CLAUDE.md) for detailed development guidance.