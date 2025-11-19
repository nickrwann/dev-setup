#!/usr/bin/env bash
set -euo pipefail

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

BASE_PATH="$HOME/src/github.com/nickrwann"
REPO_URL="${REPO_URL:-https://github.com/nickrwann/dev-setup}"
REPO_DIR="$BASE_PATH/dev-setup"

mkdir -p "$BASE_PATH"

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$REPO_DIR"
fi

ln -sf "$REPO_DIR/dotfiles/bash/.bashrc" ~/.bashrc
ln -sf "$REPO_DIR/dotfiles/git/.gitconfig" ~/.gitconfig

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
