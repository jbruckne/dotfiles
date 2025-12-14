# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository that manages macOS development environment configurations using GNU Stow for symlink management. The repository follows a shared/local configuration pattern where shared configs are tracked in git and local configs (*.local) are machine-specific and not tracked.

## Commands

### Primary CLI Tool

The main interface is the `dotfiles` CLI tool (located at the repository root):

```bash
# Install all dotfiles packages
./dotfiles

# List available packages and their installation status
./dotfiles --list

# Install specific packages only
./dotfiles --packages zsh,vim,git-config

# Migrate existing configs to local configs (preserves user settings)
./dotfiles --migrate

# Preview changes without applying them
./dotfiles --dry-run

# Revert to a previous backup
./dotfiles --revert --backup 20250504_120000

# Make dotfiles command available system-wide (creates ~/bin/dotfiles symlink)
./dotfiles --bootstrap
```

### Package Management

Available packages: `zsh`, `vim`, `git-config`, `inputrc`, `ghostty`, `zed`, `vscode`, `mise`, `starship`

Each package is a directory that gets stowed (symlinked) to `$HOME` using GNU Stow.

### Homebrew Dependencies

```bash
# Install all dependencies defined in Brewfile
brew bundle

# Check what would be installed
brew bundle check
```

## Architecture

### Shared vs Local Configuration Pattern

**Core principle**: Separate version-controlled shared configs from machine-specific local configs.

- **Shared configs**: Core settings tracked in git (e.g., `.zshrc`, `.gitconfig`)
- **Local configs**: Machine-specific overrides not tracked in git (e.g., `.gitconfig.local`, `.zsh/local.zsh`)
- **Example files**: Templates ending in `.example` that get copied to local configs during installation

Configuration loading pattern (used across all tools):
1. Load shared config
2. Load local config if it exists (using `[[ -f path ]] && source path` pattern)

### Zsh Configuration Structure

The zsh setup uses a modular architecture (zsh/.zsh/):
- `path.zsh` - PATH environment variable configuration
- `aliases.zsh` - Command aliases
- `functions.zsh` - Custom shell functions
- `prompt.zsh` - Command prompt customization
- `local.zsh` - Local overrides (not tracked, created from `local.zsh.example`)
- `pre.d/` - Scripts loaded before main config
- `post.d/` - Scripts loaded after main config

The main `.zshrc` orchestrates loading these modules in order.

### Package Organization

Each package directory mirrors the structure it creates in `$HOME`:
```
git-config/
  .gitconfig          # Shared git config
  .gitconfig.local    # Local git config (not tracked)
  .gitconfig.local.example  # Template for local config
  .gitignore_global   # Global gitignore patterns
```

Stow creates symlinks from `$HOME` to files in these package directories.

### Backup System

- Backups stored in `~/.dotfiles_backup/[timestamp]/`
- Automatic backup before installation of any existing non-symlinked files
- Can revert to any previous backup using `--revert --backup [timestamp]`

## Development Workflow

### Adding a New Configuration

1. Create package directory if needed
2. Add shared config file(s)
3. If machine-specific settings needed, create `.example` file
4. Update `PACKAGES` array in `dotfiles` script
5. Add package detection logic to `is_package_installed()` function
6. Add backup/stow logic to `install_dotfiles()` function
7. Add local config creation logic if applicable

### Modifying Existing Configs

When editing configs that support local overrides:
- Edit shared files for settings that apply to all machines
- Edit local files (*.local) for machine-specific settings
- Never commit local config files

### Testing Changes

```bash
# Preview what would happen
./dotfiles --dry-run --packages [package-name]

# Apply to specific package only
./dotfiles --packages [package-name]
```

## Important Implementation Details

### Stow Conflict Avoidance

The installation script removes existing non-symlinked files after backup to prevent Stow conflicts. Stow will fail if a target file already exists and isn't a symlink it created.

### Migration Pattern

The `--migrate` flag intelligently moves existing user configs to local config files instead of just backing them up, preserving user customizations while allowing the shared config to take effect.

### Idempotency

The CLI is designed to be run multiple times safely:
- Checks for existing installations before proceeding
- Only backs up files that aren't already symlinks
- Skips local config creation if files already exist
- Removes empty backup directories

### Bootstrap Pattern

The `--bootstrap` command creates `~/bin/dotfiles` symlink and ensures `~/bin` is in PATH, making the dotfiles command available system-wide.

## Configuration Files Locations

After installation, configs are symlinked from their package directories to these locations:
- `~/.zshrc` → `dotfiles/zsh/.zshrc`
- `~/.vimrc` → `dotfiles/vim/.vimrc`
- `~/.gitconfig` → `dotfiles/git-config/.gitconfig`
- `~/.config/ghostty/config` → `dotfiles/ghostty/.config/ghostty/config`
- `~/.config/zed/settings.json` → `dotfiles/zed/.config/zed/settings.json`
- `~/Library/Application Support/Code/User/settings.json` → `dotfiles/vscode/Library/Application Support/Code/User/settings.json`
- `~/.mise.toml` → `dotfiles/mise/.mise.toml`
- `~/.config/starship.toml` → `dotfiles/starship/.config/starship.toml`
