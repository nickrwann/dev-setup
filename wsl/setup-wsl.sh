#!/usr/bin/env bash
# Bootstraps the WSL (Ubuntu) environment: packages, starship, repo, dotfiles, uv, and VS Code extensions.

set -euo pipefail

# Ensure locally installed tools are on PATH before everything else.
export PATH="$HOME/.local/bin:$PATH"

# Canonical repo base inside WSL home.
REPO_BASE="$HOME/src/github.com/nickrwann"
DEV_SETUP_DIR="$REPO_BASE/dev-setup"

# Install VS Code extensions listed in dotfiles/vscode/extensions.txt.
install_vscode_extensions() {
  local extensions_file="$DEV_SETUP_DIR/dotfiles/vscode/extensions.txt"

  # Guard if VS Code CLI is not available.
  if ! command -v code >/dev/null 2>&1; then
    echo "VS Code command not found; skipping extension install."
    return
  fi

  # Install each non-empty, non-comment line as an extension id.
  if [ -f "$extensions_file" ]; then
    while IFS= read -r extension; do
      # Strip trailing comments.
      extension="${extension%%#*}"
      # Skip empty or whitespace-only lines.
      if [ -n "${extension// /}" ]; then
        code --install-extension "$extension" >/dev/null 2>&1 || \
          echo "Could not install VS Code extension: $extension"
      fi
    done <"$extensions_file"
  fi
}

# Update package index and install core CLI tools and build dependencies.
sudo apt update
sudo apt install -y \
  build-essential \
  pkg-config \
  libssl-dev \
  libffi-dev \
  zlib1g-dev \
  curl \
  git \
  unzip \
  ca-certificates \
  ripgrep \
  fd-find \
  fzf \
  tree

# Install starship prompt if it is not already present.
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Apply the bracketed-segments preset if starship is installed.
if command -v starship >/dev/null 2>&1; then
  mkdir -p "$HOME/.config"
  # This overwrites any existing starship.toml with the bracketed preset.
  starship preset bracketed-segments -o "$HOME/.config/starship.toml"
fi

# Ensure the repo base directory exists.
mkdir -p "$REPO_BASE"

# If dev-setup is already cloned, keep it up to date. Otherwise clone fresh.
if [ -d "$DEV_SETUP_DIR/.git" ]; then
  git -C "$DEV_SETUP_DIR" pull --ff-only
else
  git clone https://github.com/nickrwann/dev-setup "$DEV_SETUP_DIR"
fi

# Link bash and git dotfiles from the repo into $HOME.
ln -sf "$DEV_SETUP_DIR/dotfiles/bash/.bashrc" ~/.bashrc
ln -sf "$DEV_SETUP_DIR/dotfiles/git/.gitconfig" ~/.gitconfig

# Install uv if it is not already present.
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install the requested VS Code extensions after the repo is in place.
install_vscode_extensions