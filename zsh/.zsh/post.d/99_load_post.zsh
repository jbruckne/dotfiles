# Load all post-initialization scripts
# This file loads all scripts in the post.d directory

# Load all post scripts
for file in ${ZDOTDIR:-$HOME}/.zsh/post.d/*.zsh; do
  if [[ -f "$file" && "$file" != "${ZDOTDIR:-$HOME}/.zsh/post.d/99_load_post.zsh" ]]; then
    source "$file"
  fi
done

# Amazon Q post block
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"
