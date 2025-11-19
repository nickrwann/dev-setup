#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

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

if [ ! -d "$HOME/src/tooling/dev-env" ]; then
  git clone https://github.com/<your-name-here>/dev-env ~/src/tooling/dev-env
fi

ln -sf ~/src/tooling/dev-env/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/src/tooling/dev-env/dotfiles/git/.gitconfig ~/.gitconfig

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
