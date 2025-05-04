#!/usr/bin/env zsh

# Directory containing this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
cd "$DOTFILES_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Available packages
PACKAGES=(zsh vim git-config inputrc ghostty zed vscode mise)

# Backup directory
BACKUP_DIR="$HOME/.dotfiles_backup"
LATEST_BACKUP=""

# Print header
print_header() {
  echo
  echo -e "${BOLD}${BLUE}┌─────────────────────────────────────────┐${NC}"
  echo -e "${BOLD}${BLUE}│       Dotfiles Installation Script      │${NC}"
  echo -e "${BOLD}${BLUE}└─────────────────────────────────────────┘${NC}"
  echo
}

# Print section header
print_section() {
  echo
  echo -e "${BOLD}${CYAN}▶ $1${NC}"
  echo -e "${CYAN}$(printf '%.0s─' {1..50})${NC}"
}

# Print success message
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# Print info message
print_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

# Print warning message
print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

# Print error message
print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Print usage information
usage() {
  echo -e "${BOLD}Usage:${NC} $0 [options]"
  echo
  echo -e "${BOLD}Options:${NC}"
  echo "  -h, --help           Show this help message"
  echo "  -l, --list           List available dotfile packages"
  echo "  -i, --install        Install dotfiles (default if no option provided)"
  echo "  -p, --packages PKGS  Specify packages to install (comma-separated)"
  echo "  -r, --revert         Revert to backup (must specify --backup)"
  echo "  -b, --backup DIR     Specify backup directory for revert"
  echo "  -n, --dry-run        Show what would be done without making changes"
  echo "  -m, --migrate        Migrate existing configs to local configs"
  echo
  echo -e "${BOLD}Examples:${NC}"
  echo "  $0 --install                  # Install all dotfiles"
  echo "  $0 --packages zsh,vim         # Install only zsh and vim configs"
  echo "  $0 --list                     # List available packages"
  echo "  $0 --install --migrate        # Install and migrate existing configs"
  echo "  $0 --revert --backup 20250504_120000  # Revert to specific backup"
  echo "  $0 --dry-run --migrate        # Preview migration without changes"
  echo
}

# List available packages
list_packages() {
  print_section "Available Packages"
  
  for pkg in "${PACKAGES[@]}"; do
    echo -e "${BOLD}${pkg}${NC}"
    case "$pkg" in
      zsh)
        echo "  Shell configuration (.zshrc, .zsh/)"
        ;;
      vim)
        echo "  Vim editor configuration (.vimrc)"
        ;;
      git-config)
        echo "  Git configuration (.gitconfig, .gitignore_global)"
        ;;
      inputrc)
        echo "  Readline configuration (.inputrc)"
        ;;
      ghostty)
        echo "  Ghostty terminal configuration (.config/ghostty/)"
        ;;
      zed)
        echo "  Zed editor configuration (.config/zed/)"
        ;;
      vscode)
        echo "  VS Code configuration (Library/Application Support/Code/User/)"
        ;;
      mise)
        echo "  Mise version manager configuration (.mise.toml)"
        ;;
    esac
  done
}

# List available backups
list_backups() {
  print_section "Available Backups"
  
  if [[ ! -d "$BACKUP_DIR" ]]; then
    print_warning "No backups found."
    return 1
  fi
  
  local backups=($(ls -1 "$BACKUP_DIR"))
  
  if [[ ${#backups[@]} -eq 0 ]]; then
    print_warning "No backups found."
    return 1
  fi
  
  echo -e "${BOLD}Backup ID${NC}               ${BOLD}Date${NC}"
  echo "----------------------------------------"
  
  for backup in "${backups[@]}"; do
    local date_str=$(echo "$backup" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
    echo "$backup        $date_str"
  done
  
  return 0
}

# Check if Homebrew is installed and install if needed
check_homebrew() {
  if ! command -v brew &> /dev/null; then
    print_warning "Homebrew is not installed. Would you like to install it? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      print_info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      print_warning "Homebrew installation skipped. Some features may not work."
    fi
  fi

  # Install packages from Brewfile if Homebrew is installed
  if command -v brew &> /dev/null; then
    print_info "Installing packages from Brewfile..."
    if [[ "$DRY_RUN" == "true" ]]; then
      print_info "DRY RUN: Would install packages from Brewfile"
    else
      brew bundle
    fi
  fi

  # Check if stow is installed
  if ! command -v stow &> /dev/null; then
    print_error "GNU Stow is not installed. Please install it first."
    print_info "On macOS: brew install stow"
    print_info "On Ubuntu/Debian: apt-get install stow"
    exit 1
  fi
}

# Function to backup a file or directory
backup_if_exists() {
  local file="$1"
  if [[ -e "$file" && ! -L "$file" ]]; then
    print_info "Backing up existing $file to $LATEST_BACKUP"
    if [[ "$DRY_RUN" != "true" ]]; then
      mkdir -p "$LATEST_BACKUP"
      cp -R "$file" "$LATEST_BACKUP/"
    fi
    return 0
  elif [[ -L "$file" ]]; then
    print_info "Removing existing symlink $file"
    if [[ "$DRY_RUN" != "true" ]]; then
      rm "$file"
    fi
    return 0
  fi
  return 1
}

# Function to create local config files from examples
create_local_config() {
  local example_file="$1"
  local target_file="${example_file%.example}"
  
  if [[ ! -f "$target_file" ]]; then
    if [[ -f "$HOME/$(basename "$target_file")" && ! -L "$HOME/$(basename "$target_file")" && "$MIGRATE" == "true" ]]; then
      print_info "Found existing $(basename "$target_file") in home directory. Migrating to local config..."
      if [[ "$DRY_RUN" != "true" ]]; then
        cp "$HOME/$(basename "$target_file")" "$target_file"
      fi
      print_success "Migrated $(basename "$target_file") to $target_file"
    else
      print_info "Creating $target_file from example..."
      if [[ "$DRY_RUN" != "true" ]]; then
        cp "$example_file" "$target_file"
      fi
    fi
  else
    print_info "Local config $target_file already exists. Skipping..."
  fi
}

# Install dotfiles
install_dotfiles() {
  local packages_to_install=("$@")
  
  # Create latest backup directory
  LATEST_BACKUP="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"
  
  # Create directories if they don't exist
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$HOME/.zsh"
  fi

  # Handle existing config files that might conflict with stow
  print_section "Checking for existing configuration files"

  for pkg in "${packages_to_install[@]}"; do
    case "$pkg" in
      zsh)
        if [[ "$MIGRATE" == "true" ]]; then
          # Migrate zsh configs to local
          if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
            print_info "Migrating .zshrc to local config..."
            if [[ "$DRY_RUN" != "true" ]]; then
              mkdir -p "$DOTFILES_DIR/zsh/.zsh"
              cp "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zsh/local.zsh"
              print_success "Migrated .zshrc to .zsh/local.zsh"
            fi
          fi
        fi
        backup_if_exists "$HOME/.zshrc"
        backup_if_exists "$HOME/.zsh"
        # Remove the original file after backup to avoid stow conflicts
        if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/.zshrc"
        fi
        ;;
      vim)
        if [[ "$MIGRATE" == "true" ]]; then
          # Migrate vim configs to local
          if [[ -f "$HOME/.vimrc" && ! -L "$HOME/.vimrc" ]]; then
            print_info "Migrating .vimrc to local config..."
            if [[ "$DRY_RUN" != "true" ]]; then
              cp "$HOME/.vimrc" "$DOTFILES_DIR/vim/.vimrc.local"
              print_success "Migrated .vimrc to .vimrc.local"
            fi
          fi
        fi
        backup_if_exists "$HOME/.vimrc"
        # Remove the original file after backup to avoid stow conflicts
        if [[ -f "$HOME/.vimrc" && ! -L "$HOME/.vimrc" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/.vimrc"
        fi
        ;;
      git-config)
        if [[ "$MIGRATE" == "true" ]]; then
          # Migrate git configs to local
          if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
            print_info "Migrating .gitconfig to local config..."
            if [[ "$DRY_RUN" != "true" ]]; then
              cp "$HOME/.gitconfig" "$DOTFILES_DIR/git-config/.gitconfig.local"
              print_success "Migrated .gitconfig to .gitconfig.local"
            fi
          fi
        fi
        backup_if_exists "$HOME/.gitconfig"
        backup_if_exists "$HOME/.gitignore_global"
        # Remove the original file after backup to avoid stow conflicts
        if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/.gitconfig"
        fi
        ;;
      inputrc)
        backup_if_exists "$HOME/.inputrc"
        # Remove the original file after backup to avoid stow conflicts
        if [[ -f "$HOME/.inputrc" && ! -L "$HOME/.inputrc" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/.inputrc"
        fi
        ;;
      ghostty)
        backup_if_exists "$HOME/.config/ghostty"
        # Remove the original directory after backup to avoid stow conflicts
        if [[ -d "$HOME/.config/ghostty" && ! -L "$HOME/.config/ghostty" && "$DRY_RUN" != "true" ]]; then
          rm -rf "$HOME/.config/ghostty"
        fi
        ;;
      zed)
        backup_if_exists "$HOME/.config/zed/settings.json"
        # Remove the original file after backup to avoid stow conflicts
        if [[ -f "$HOME/.config/zed/settings.json" && ! -L "$HOME/.config/zed/settings.json" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/.config/zed/settings.json"
        fi
        ;;
      vscode)
        backup_if_exists "$HOME/Library/Application Support/Code/User/settings.json"
        backup_if_exists "$HOME/Library/Application Support/Code/User/keybindings.json"
        # Remove the original files after backup to avoid stow conflicts
        if [[ -f "$HOME/Library/Application Support/Code/User/settings.json" && ! -L "$HOME/Library/Application Support/Code/User/settings.json" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/Library/Application Support/Code/User/settings.json"
        fi
        if [[ -f "$HOME/Library/Application Support/Code/User/keybindings.json" && ! -L "$HOME/Library/Application Support/Code/User/keybindings.json" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/Library/Application Support/Code/User/keybindings.json"
        fi
        ;;
      mise)
        backup_if_exists "$HOME/.mise.toml"
        # Remove the original file after backup to avoid stow conflicts
        if [[ -f "$HOME/.mise.toml" && ! -L "$HOME/.mise.toml" && "$DRY_RUN" != "true" ]]; then
          rm "$HOME/.mise.toml"
        fi
        ;;
    esac
  done

  # Create local config files from examples
  print_section "Setting up local configuration files"
  
  for pkg in "${packages_to_install[@]}"; do
    case "$pkg" in
      zsh)
        create_local_config "$DOTFILES_DIR/zsh/.zsh/local.zsh.example"
        ;;
      vim)
        create_local_config "$DOTFILES_DIR/vim/.vimrc.local.example"
        ;;
      git-config)
        create_local_config "$DOTFILES_DIR/git-config/.gitconfig.local.example"
        ;;
      ghostty)
        create_local_config "$DOTFILES_DIR/ghostty/.config/ghostty/config.local.example"
        ;;
      mise)
        create_local_config "$DOTFILES_DIR/mise/.mise.local.toml.example"
        # Trust the mise local config file to prevent warnings
        if command -v mise &> /dev/null && [[ -f "$HOME/.mise.local.toml" ]]; then
          print_info "Trusting mise local config file..."
          if [[ "$DRY_RUN" != "true" ]]; then
            mise trust "$HOME/.mise.local.toml" &>/dev/null || true
            print_success "Trusted mise local config file"
          fi
        fi
        ;;
    esac
  done

  # Stow each package
  print_section "Stowing dotfiles"
  
  for pkg in "${packages_to_install[@]}"; do
    print_info "Stowing $pkg..."
    if [[ "$DRY_RUN" == "true" ]]; then
      print_info "DRY RUN: Would stow $pkg"
    else
      # Explicitly specify the target directory to ensure proper symlink creation
      stow -v --no-folding --target="$HOME" "$pkg"
    fi
  done

  print_success "Dotfiles installation complete!"

  if [[ -d "$LATEST_BACKUP" && "$(ls -A "$LATEST_BACKUP" 2>/dev/null)" ]]; then
    print_info "Your original configuration files were backed up to: $LATEST_BACKUP"
  elif [[ "$DRY_RUN" != "true" ]]; then
    # Remove empty backup directory if nothing was backed up
    rmdir "$LATEST_BACKUP" 2>/dev/null
  fi

  print_info "Note: You may need to restart your shell for changes to take effect."
}

# Revert to backup
revert_to_backup() {
  local backup_id="$1"
  local backup_path="$BACKUP_DIR/$backup_id"
  
  if [[ ! -d "$backup_path" ]]; then
    print_error "Backup $backup_id not found."
    list_backups
    exit 1
  fi
  
  print_section "Reverting to backup $backup_id"
  
  # Unstow all packages first
  for pkg in "${PACKAGES[@]}"; do
    print_info "Unstowing $pkg..."
    if [[ "$DRY_RUN" == "true" ]]; then
      print_info "DRY RUN: Would unstow $pkg"
    else
      stow -D "$pkg" 2>/dev/null || true
    fi
  done
  
  # Restore files from backup
  for file in $(ls -A "$backup_path"); do
    print_info "Restoring $file to $HOME"
    if [[ "$DRY_RUN" == "true" ]]; then
      print_info "DRY RUN: Would restore $file"
    else
      cp -R "$backup_path/$file" "$HOME/"
    fi
  done
  
  print_success "Reverted to backup $backup_id"
}

# Parse command line options
zparseopts -D -E -F -K -- \
  h=help -help=help \
  l=list -list=list \
  i=install -install=install \
  p:=pkg_opt -packages:=pkg_opt \
  r=revert -revert=revert \
  b:=backup_opt -backup:=backup_opt \
  n=dry_run -dry-run=dry_run \
  m=migrate -migrate=migrate

# Set default action if none specified
if [[ ${#help} -eq 0 && ${#list} -eq 0 && ${#install} -eq 0 && ${#revert} -eq 0 ]]; then
  install=1
fi

# Set dry run flag
DRY_RUN="false"
if [[ ${#dry_run} -gt 0 ]]; then
  DRY_RUN="true"
  print_warning "DRY RUN MODE: No changes will be made"
fi

# Set migrate flag
MIGRATE="false"
if [[ ${#migrate} -gt 0 ]]; then
  MIGRATE="true"
  print_info "MIGRATE MODE: Existing configs will be migrated to local configs"
fi

# Print header
print_header

# Process options
if [[ ${#help} -gt 0 ]]; then
  usage
  exit 0
fi

if [[ ${#list} -gt 0 ]]; then
  list_packages
  echo
  list_backups
  exit 0
fi

if [[ ${#revert} -gt 0 ]]; then
  if [[ ${#backup_opt} -eq 0 ]]; then
    print_error "You must specify a backup ID with --backup"
    list_backups
    exit 1
  fi
  
  revert_to_backup "${backup_opt[-1]#*=}"
  exit 0
fi

if [[ ${#install} -gt 0 || ${#pkg_opt} -gt 0 ]]; then
  # Check for Homebrew and required tools
  check_homebrew
  
  # Determine which packages to install
  if [[ ${#pkg_opt} -gt 0 ]]; then
    IFS=',' read -A selected_packages <<< "${pkg_opt[-1]#*=}"
    
    # Validate selected packages
    for pkg in "${selected_packages[@]}"; do
      if [[ ! " ${PACKAGES[@]} " =~ " ${pkg} " ]]; then
        print_error "Unknown package: $pkg"
        list_packages
        exit 1
      fi
    done
  else
    selected_packages=("${PACKAGES[@]}")
  fi
  
  # Install selected packages
  install_dotfiles "${selected_packages[@]}"
  exit 0
fi

# Should never reach here
print_error "Invalid options combination"
usage
exit 1
