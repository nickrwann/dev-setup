#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

REPO_BASE="$HOME/src/github.com/nickrwann"
DEV_SETUP_DIR="$REPO_BASE/dev-setup"

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
  fzf

if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if command -v starship >/dev/null 2>&1; then
  mkdir -p "$HOME/.config"
  starship preset bracketed-segments -o "$HOME/.config/starship.toml"
fi

mkdir -p "$REPO_BASE"

if [ -d "$DEV_SETUP_DIR/.git" ]; then
  git -C "$DEV_SETUP_DIR" pull --ff-only
else
  git clone https://github.com/nickrwann/dev-setup "$DEV_SETUP_DIR"
fi

ln -sf "$DEV_SETUP_DIR/dotfiles/bash/.bashrc" ~/.bashrc
ln -sf "$DEV_SETUP_DIR/dotfiles/git/.gitconfig" ~/.gitconfig

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
