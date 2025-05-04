# Prompt configuration

# Initialize Starship prompt if available
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
else
  # Fallback prompt if Starship is not available
  autoload -Uz vcs_info
  precmd() { vcs_info }

  zstyle ':vcs_info:git:*' formats '%b'
  
  # Simple prompt with git branch
  PROMPT='%F{blue}%~%f %F{green}${vcs_info_msg_0_}%f %F{yellow}→%f '
fi
