# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository for cross-platform development environment setup (macOS and Linux). It manages configuration files for developer tools and provides automated bootstrap scripts for setting up new machines.

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # Chezmoi config with OS detection
├── .shared/                    # Shared configurations (symlinked)
│   └── vscode-cursor/         # VS Code & Cursor settings (used by both apps on both OSes)
│       ├── settings.json.tmpl
│       └── keybindings.json
├── bootstrap/                  # Bootstrap scripts for initial setup
│   ├── macos.sh               # macOS-specific setup
│   ├── linux.sh               # Linux/Ubuntu setup
│   └── common.sh              # Shared functions
├── scripts/                    # Utility scripts
│   ├── install-tools.sh.tmpl  # Development tools installation
│   └── setup-nvim.sh.tmpl     # Neovim configuration setup
├── dot_zshrc.tmpl             # Zsh configuration with OS templating
├── dot_zshenv                 # Zsh environment variables
├── dot_config/                # Linux app configurations (~/.config/)
│   ├── Code/User/             # VS Code settings (symlinks to .shared/)
│   └── Cursor/User/           # Cursor settings (symlinks to .shared/)
├── private_Library/           # macOS app configurations (~/Library/)
│   └── Application Support/
│       ├── Code/User/         # VS Code settings (symlinks to .shared/)
│       └── Cursor/User/       # Cursor settings (symlinks to .shared/)
├── run_once_*.sh.tmpl         # Chezmoi run-once scripts
└── mac-setup-steps.md         # Historical setup documentation
```

## Common Commands

### Initial Setup (New Machine)
```bash
# Run appropriate bootstrap script first
./bootstrap/macos.sh    # On macOS
./bootstrap/linux.sh    # On Linux

# Initialize chezmoi and apply dotfiles
chezmoi init --apply https://github.com/micah-svenson/dotfiles.git
```

### Daily Chezmoi Operations
```bash
chezmoi add ~/.zshrc           # Add new dotfile to management
chezmoi edit ~/.zshrc          # Edit managed dotfile
chezmoi apply                  # Apply all changes
chezmoi diff                   # See what would change
chezmoi status                 # Check repository status
chezmoi update                 # Pull and apply latest changes
```

### Development Tools
```bash
./scripts/install-tools.sh     # Install development tools
./scripts/setup-nvim.sh        # Setup Neovim configuration
```

## Key Integrations

- **Neovim**: Automatically clones separate config from `https://github.com/micah-svenson/neovim-config.git`
- **VS Code/Cursor**: Shared settings and keybindings managed together
- **Zsh**: oh-my-zsh integration with cross-platform aliases and functions
- **Development Tools**: Automated installation of ripgrep, fzf, git-delta, language servers

## Template Variables

The repository uses chezmoi templates with these variables:
- `{{ .is_macos }}` / `{{ .is_linux }}` - OS detection
- `{{ .package_manager }}` - "brew" or "apt"
- `{{ .chezmoi.hostname }}` / `{{ .chezmoi.username }}` - System info

## VS Code & Cursor Configuration

The repository uses a shared configuration approach for VS Code and Cursor across both macOS and Ubuntu:

**Canonical Files**: `.shared/vscode-cursor/settings.json.tmpl` and `.shared/vscode-cursor/keybindings.json`

**Deployment Strategy**: Chezmoi creates symlinks from the platform-specific locations to the shared files:
- **macOS**: `~/Library/Application Support/{Code,Cursor}/User/` → `.shared/vscode-cursor/`
- **Ubuntu**: `~/.config/{Code,Cursor}/User/` → `.shared/vscode-cursor/`

**To Edit Settings**:
```bash
# Edit the canonical files
chezmoi edit ~/.local/share/chezmoi/.shared/vscode-cursor/settings.json.tmpl
chezmoi edit ~/.local/share/chezmoi/.shared/vscode-cursor/keybindings.json

# Apply to all locations
chezmoi apply
```

## Notes

- Bootstrap scripts handle initial tool installation and system setup
- run_once scripts ensure tools are installed when chezmoi is applied
- VS Code and Cursor share identical configurations via symlinks to `.shared/vscode-cursor/`
- All 4 combinations (VS Code/Cursor × macOS/Ubuntu) use the same settings
- Browser bookmark syncing not yet implemented (future enhancement)