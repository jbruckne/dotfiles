# .zshrc - Zsh configuration file

# Set Paths
source ~/.path

# Set Default Editor
export EDITOR=/usr/bin/vim

# Set default blocksize for ls, df, du
export BLOCKSIZE=1k

# Load custom configurations
source ~/.env
source ~/.alias
source ~/.function
source ~/.prompt

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # share history across multiple zsh sessions
setopt APPEND_HISTORY         # append to history
setopt INC_APPEND_HISTORY     # add commands as they are typed, not at shell exit
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicates first
setopt HIST_IGNORE_DUPS       # do not store duplications
setopt HIST_IGNORE_SPACE      # ignore commands that start with space
setopt HIST_VERIFY            # show command with history expansion before running it

# Completion system
autoload -Uz compinit
compinit

# Enable colors
autoload -Uz colors
colors

# Key bindings
bindkey -e  # Use emacs key bindings (default)

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS    # do not store duplicates in the stack
setopt PUSHD_SILENT         # do not print the directory stack after pushd or popd

# Correction
setopt CORRECT              # command auto-correction
setopt CORRECT_ALL          # argument auto-correction
