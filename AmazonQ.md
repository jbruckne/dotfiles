# Dotfiles Management with GNU Stow

This document explains how the dotfiles repository is structured and managed using GNU Stow.

## What is GNU Stow?

GNU Stow is a symlink farm manager that allows you to keep your dotfiles in a separate directory and create symbolic links to them from your home directory. This makes it easy to:

- Keep all your configuration files in one place
- Track changes with version control
- Deploy the same configuration across multiple machines
- Separate shared and local configurations

## Repository Structure

Each package (zsh, vim, git-config, etc.) is organized in a way that mirrors how it should appear in your home directory:

```
dotfiles/
├── zsh/
│   ├── .zshrc              -> ~/
│   └── .zsh/               -> ~/.zsh/
│       ├── aliases.zsh
│       ├── functions.zsh
│       ├── path.zsh
│       ├── prompt.zsh
│       └── local.zsh.example
├── vim/
│   ├── .vimrc              -> ~/
│   └── .vimrc.local.example
├── git-config/
│   ├── .gitconfig          -> ~/
│   ├── .gitignore_global   -> ~/
│   └── .gitconfig.local.example
├── inputrc/
│   └── .inputrc           -> ~/
└── Brewfile               # Homebrew packages
```

## How Stow Works

When you run `stow zsh`, it creates symbolic links from your home directory to the files in the `zsh/` directory. For example:

- `~/dotfiles/zsh/.zshrc` → `~/.zshrc`
- `~/dotfiles/zsh/.zsh/aliases.zsh` → `~/.zsh/aliases.zsh`

## Shared vs Local Configuration

This setup separates shared configuration (tracked in git) from local configuration (not tracked):

1. **Shared configuration files** are stored directly in the repository
2. **Local configuration examples** are provided as `.example` files
3. The `install.sh` script creates local configuration files from examples if they don't exist
4. Local configuration files are listed in `.gitignore` to prevent them from being tracked

This approach allows you to:
- Share common settings across machines
- Keep sensitive or machine-specific settings private
- Experiment with changes locally before committing them to the shared configuration
