# Load all pre-initialization scripts
# This file loads all scripts in the pre.d directory

# VSCode shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && \
  . "$(code --locate-shell-integration-path zsh)"

# Load all other pre scripts
for file in ${ZDOTDIR:-$HOME}/.zsh/pre.d/*.zsh; do
  if [[ -f "$file" && "$file" != "${ZDOTDIR:-$HOME}/.zsh/pre.d/00_load_pre.zsh" ]]; then
    source "$file"
  fi
done
