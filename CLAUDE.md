# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository for cross-platform development environment setup (macOS, Linux, and WSL). It manages configuration files for developer tools and provides automated bootstrap scripts for setting up new machines.

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl                    # Chezmoi config with OS/WSL detection
├── .chezmoitemplates/                    # Shared templates (chezmoi standard)
│   └── vscode-cursor/                   # VS Code & Cursor canonical settings
│       ├── settings.json                # Shared settings for all platforms
│       └── keybindings.json             # Shared keybindings for all platforms
├── bootstrap/                            # Bootstrap scripts for initial setup
│   ├── macos.sh                         # macOS-specific setup
│   ├── linux.sh                         # Linux/Ubuntu setup
│   └── common.sh                        # Shared functions
├── scripts/                              # Utility scripts
│   ├── install-tools.sh.tmpl            # Development tools installation
│   └── setup-nvim.sh.tmpl               # Neovim configuration setup
├── dot_zshrc.tmpl                       # Zsh configuration with OS templating
├── dot_zshenv                           # Zsh environment variables
├── dot_config/                          # Linux app configurations (~/.config/)
│   ├── Code/User/                       # VS Code settings (symlinks to .chezmoitemplates/)
│   └── Cursor/User/                     # Cursor settings (symlinks to .chezmoitemplates/)
├── private_Library/                     # macOS app configurations (~/Library/)
│   └── Application Support/
│       ├── Code/User/                   # VS Code settings (symlinks to .chezmoitemplates/)
│       └── Cursor/User/                 # Cursor settings (symlinks to .chezmoitemplates/)
├── run_once_*.sh.tmpl                   # Chezmoi run-once scripts
├── run_onchange_before_sync-vscode-to-windows.sh.tmpl  # WSL → Windows sync script
└── mac-setup-steps.md                   # Historical setup documentation
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
- `{{ .is_macos }}` / `{{ .is_linux }}` / `{{ .is_wsl }}` - OS detection
- `{{ .package_manager }}` - "brew" or "apt"
- `{{ .windows_username }}` - Windows username (WSL only, prompted on first run)
- `{{ .chezmoi.hostname }}` / `{{ .chezmoi.username }}` - System info

## VS Code & Cursor Configuration

The repository uses a shared configuration approach for VS Code and Cursor across macOS, Linux, and Windows (via WSL):

**Canonical Files**: `.chezmoitemplates/vscode-cursor/settings.json` and `.chezmoitemplates/vscode-cursor/keybindings.json`

**Deployment Strategy**:
- **macOS**: Symlinks from `~/Library/Application Support/{Code,Cursor}/User/` → `.chezmoitemplates/vscode-cursor/`
- **Linux**: Symlinks from `~/.config/{Code,Cursor}/User/` → `.chezmoitemplates/vscode-cursor/`
- **Windows (via WSL)**: Automated copy via `run_onchange` script to `/mnt/c/Users/<username>/AppData/Roaming/{Code,Cursor}/User/`

**To Edit Settings**:
```bash
# Edit the canonical files (in the source directory)
chezmoi edit ~/.local/share/chezmoi/.chezmoitemplates/vscode-cursor/settings.json
chezmoi edit ~/.local/share/chezmoi/.chezmoitemplates/vscode-cursor/keybindings.json

# Or edit directly
vim ~/.local/share/chezmoi/.chezmoitemplates/vscode-cursor/settings.json

# Apply to all locations (macOS/Linux symlinks + Windows copy on WSL)
chezmoi apply
```

**WSL → Windows Sync**:
The `run_onchange_before_sync-vscode-to-windows.sh.tmpl` script automatically copies settings to Windows when files change. It uses checksums to detect changes and only runs on WSL systems.

## Notes

- Bootstrap scripts handle initial tool installation and system setup
- `run_once_*` scripts ensure tools are installed when chezmoi is applied
- `run_onchange_*` scripts re-run when their embedded checksums change (e.g., Windows sync)
- VS Code and Cursor share identical configurations via `.chezmoitemplates/vscode-cursor/`
- All platforms (macOS, Linux, WSL/Windows) use the same settings
- WSL automatically syncs settings to Windows side via copy (not symlink, as WSL→Windows symlinks don't work reliably)
- Browser bookmark syncing not yet implemented (future enhancement)