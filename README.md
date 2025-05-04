# Dotfiles

A collection of configuration files and scripts for customizing my macOS development environment.

## Overview

This repository contains configuration files for:
- Zsh shell environment (`.zshrc`)
- Vim editor (`.vimrc`)
- Git configuration (`.gitconfig`, `.gitignore_global`)
- Input configuration (`.inputrc`)
- Ghostty terminal emulator (`.config/ghostty/config`)
- Zed editor (`.config/zed/settings.json`)
- VS Code editor (settings and keybindings)
- Mise version manager (`.mise.toml`)
- Homebrew bundle (Brewfile) for installing common tools

## Directory Structure

- `zsh/`: Zsh configuration files
- `vim/`: Vim configuration files
- `git-config/`: Git configuration files
- `inputrc/`: Readline configuration
- `ghostty/`: Ghostty terminal configuration
- `zed/`: Zed editor configuration
- `vscode/`: VS Code editor configuration
- `mise/`: Mise version manager configuration
- `local/`: Local configuration templates (not tracked by git)

## Installation

This dotfiles repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks.

### Prerequisites

The installation script will attempt to install Homebrew and required packages automatically. If you prefer to install them manually:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages from Brewfile
brew bundle
```

### Setup

The dotfiles CLI provides several options:

```bash
# Install all dotfiles (default)
dotfiles

# List available packages and backups
dotfiles --list

# Install specific packages
dotfiles --packages zsh,vim

# Migrate existing configs to local configs
dotfiles --migrate

# Dry run to see what would happen without making changes
dotfiles --dry-run

# Revert to a previous backup
dotfiles --revert --backup 20250504_120000

# Make dotfiles command available system-wide
dotfiles --bootstrap
```

When installing, the script will:
1. Install Homebrew if not already installed (with your permission)
2. Install packages from the Brewfile
3. Back up any existing configuration files to `~/.dotfiles_backup/[timestamp]/`
4. Migrate existing configuration to local config files when appropriate
5. Create local configuration files from examples if they don't exist
6. Create symbolic links from your home directory to the files in this repository
7. Make the `dotfiles` command available system-wide

The dotfiles CLI is designed to be idempotent - you can run it multiple times safely.

## Customization

### Shared vs Local Configuration

This dotfiles setup maintains a separation between shared configuration (tracked in git) and local configuration (not tracked):

- **Shared configuration**: Core settings that you want to use across all machines
- **Local configuration**: Machine-specific settings, private information, or experimental changes

### Zsh Configuration
The zsh configuration is split into modular files:
- `path.zsh`: Configures the PATH environment variable
- `aliases.zsh`: Defines command aliases
- `functions.zsh`: Contains custom shell functions
- `prompt.zsh`: Customizes the command prompt
- `local.zsh`: Local configuration (not tracked in git)
- `pre.d/`: Pre-initialization scripts (loaded before main config)
- `post.d/`: Post-initialization scripts (loaded after main config)

### Vim Configuration
- `.vimrc`: Core vim settings
- `.vimrc.local`: Local vim settings (not tracked in git)

### Git Configuration
- `.gitconfig`: Core git settings
- `.gitignore_global`: Global git ignore patterns
- `.gitconfig.local`: Local git settings (not tracked in git)

### Ghostty Configuration
- `config`: Core ghostty settings
- `config.local`: Local ghostty settings (not tracked in git)

### Zed Configuration
- `settings.json`: Zed editor settings

### VS Code Configuration
- `settings.json`: VS Code settings
- `keybindings.json`: VS Code key bindings

### Mise Configuration
- `.mise.toml`: Core mise settings
- `.mise.local.toml`: Local mise settings (not tracked in git)

## Updating

To update your dotfiles after making changes:

```bash
# Re-run the dotfiles command for the updated package
dotfiles --packages zsh  # Replace 'zsh' with the package you modified
```

## License

This project is open source and available under the [MIT License](LICENSE).
