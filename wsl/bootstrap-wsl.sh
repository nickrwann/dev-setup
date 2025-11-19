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
  if ! git -C "$REPO_DIR" diff --quiet || ! git -C "$REPO_DIR" diff --quiet --cached; then
    echo "Existing dev-setup checkout at $REPO_DIR has local changes." >&2
    echo "Please commit, stash, or discard those changes before rerunning this script." >&2
    exit 1
  fi

  if git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
    git -C "$REPO_DIR" remote set-url origin "$REPO_URL"
  fi

  if ! git -C "$REPO_DIR" pull --ff-only; then
    echo "Unable to fast-forward $REPO_DIR. Resolve any git conflicts and re-run the bootstrap." >&2
    exit 1
  fi
else
  git clone "$REPO_URL" "$REPO_DIR"
fi

ln -sf "$REPO_DIR/dotfiles/bash/.bashrc" ~/.bashrc
ln -sf "$REPO_DIR/dotfiles/git/.gitconfig" ~/.gitconfig

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
