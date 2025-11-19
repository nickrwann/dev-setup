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

mkdir -p ~/src/{personal,work,tooling}

if [ ! -d "$HOME/src/tooling/dev-env" ]; then
  git clone https://github.com/<your-name-here>/dev-env ~/src/tooling/dev-env
fi

ln -sf ~/src/tooling/dev-env/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/src/tooling/dev-env/dotfiles/git/.gitconfig ~/.gitconfig

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
