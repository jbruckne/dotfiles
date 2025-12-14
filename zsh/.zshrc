# .zshrc - Zsh configuration file

# Load pre-initialization scripts
[[ -f ~/.zsh/pre.d/00_load_pre.zsh ]] && source ~/.zsh/pre.d/00_load_pre.zsh

# Set Default Editor
# Options: /usr/bin/vim, hx (helix), code --wait (vscode), zed --wait
export EDITOR=/usr/bin/vim

# Set default blocksize for ls, df, du
export BLOCKSIZE=1k

# Load shared configurations
[[ -f ~/.zsh/path.zsh ]] && source ~/.zsh/path.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh
[[ -f ~/.zsh/prompt.zsh ]] && source ~/.zsh/prompt.zsh

# Load local configurations (not tracked in git)
[[ -f ~/.zsh/local.zsh ]] && source ~/.zsh/local.zsh

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

# Initialize mise
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Initialize zoxide (smarter cd with frecency)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # Use 'z' to jump to directories, 'zi' for interactive selection
fi

# Initialize fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  # Key bindings: Ctrl-R (history), Ctrl-T (files), Alt-C (cd directories)
  source <(fzf --zsh)
fi

# Initialize thefuck (corrects previous console commands)
if command -v thefuck &> /dev/null; then
  eval "$(thefuck --alias)"
  # Now you can type 'fuck' after a command fails to get suggestions
  # Example: brew update vim -> fuck -> suggests: brew upgrade vim
fi

# Load post-initialization scripts
[[ -f ~/.zsh/post.d/99_load_post.zsh ]] && source ~/.zsh/post.d/99_load_post.zsh
export PATH="$HOME/bin:$PATH"
alias claude="/Users/joebruckner/.claude/local/claude"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
