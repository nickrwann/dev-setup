export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -alF'
alias gs='git status'
alias gd='git diff'
alias venv='source .venv/bin/activate'

if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion bash)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
