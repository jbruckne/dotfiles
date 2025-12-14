# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List directory contents (eza: modern ls replacement with colors, git integration, icons)
if command -v eza &> /dev/null; then
  # Basic listing with color and directories first
  alias ls='eza --color=always --group-directories-first'
  # Long format (-l) with human-readable sizes (-h), git status, directories first
  alias ll='eza -lh --git --group-directories-first'
  # Same as ll but including hidden files (-a)
  alias la='eza -lah --git --group-directories-first'
  # Compact listing
  alias l='eza --group-directories-first'
  # Tree view: 2 levels deep, with git status (no size/user clutter)
  alias lt='eza --tree --level=2 --git'
  # Tree view including hidden files
  alias lta='eza --tree --level=2 --git -a'
else
  # Fallback to standard ls if eza not installed
  alias ls='ls -G'
  alias ll='ls -lh'
  alias la='ls -lha'
  alias l='ls -CF'
fi

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# System
alias reload='source ~/.zshrc'
alias edit='$EDITOR'

# Show/hide hidden files in Finder
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# Modern Unix tools - helper aliases
# Use actual command names: rg, fd, bat, duf, dust, procs, etc.

# ripgrep helpers
if command -v rg &> /dev/null; then
  # Search everything including ignored/hidden files
  alias rga='rg --no-ignore --hidden'
fi

# fd helpers
if command -v fd &> /dev/null; then
  # Search everything including ignored/hidden files
  alias fda='fd --no-ignore --hidden'
fi

# bat helpers
if command -v bat &> /dev/null; then
  # Plain output (useful for piping)
  alias batp='bat --style=plain'
  # Show all (non-printable characters)
  alias bata='bat --show-all'
fi

# tealdeer (tldr): simplified man pages with practical examples
# Just use as: tldr <command>
# Example: tldr tar
# Tip: Run 'tldr --update' periodically to get latest examples

# httpie: user-friendly HTTP client (better than curl for APIs)
# Just use as: http <url> or https <url>
# Example: http GET https://api.github.com/users/octocat

# hyperfine: command-line benchmarking
# Just use as: hyperfine 'command1' 'command2'
# Example: hyperfine 'fd' 'find'

# sd: sed alternative with simpler syntax
# Just use as: sd 'find' 'replace' file.txt
# Example: sd 'foo' 'bar' *.txt

# ast-grep (sg): structural search/replace based on AST
# Just use as: sg --pattern 'pattern' or ast-grep --pattern 'pattern'
# Example: sg --pattern 'console.log($$$)' to find all console.log calls
# Example: sg --pattern 'function $FUNC($$$) { $$$ }' to find function declarations

# helix (hx): modern modal text editor (alternative to vim/neovim)
# Just use as: hx file.txt
# Tip: ':tutor' inside helix for interactive tutorial

# mosh: mobile shell for SSH (better for unstable connections)
# Just use as: mosh user@host
# Works like SSH but handles disconnections and roaming
