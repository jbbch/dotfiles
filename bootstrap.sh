#!/usr/bin/env bash
set -euo pipefail

# One-command installer for this repo.
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jbbch/dotfiles/main/bootstrap.sh)"
#
# Optional overrides:
#   DOTFILES_REPO_URL=https://github.com/you/dotfiles.git \
#   DOTFILES_BRANCH=main \
#   DOTFILES_DIR=$HOME/dotfiles \
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/you/dotfiles/main/bootstrap.sh)"

DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-https://github.com/jbbch/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_TARBALL_URL="${DOTFILES_TARBALL_URL:-https://github.com/jbbch/dotfiles/archive/refs/heads/${DOTFILES_BRANCH}.tar.gz}"
BACKUP_PARENT="$HOME/.dotfiles-bootstrap-backups"

log() {
  printf '\n==> %s\n' "$1"
}

backup_existing_dotfiles_dir() {
  if [ ! -e "$DOTFILES_DIR" ]; then
    return
  fi

  if [ -d "$DOTFILES_DIR/.git" ]; then
    return
  fi

  mkdir -p "$BACKUP_PARENT"
  local backup_dir="$BACKUP_PARENT/$(date +%Y%m%d-%H%M%S)"
  log "Backing up existing $DOTFILES_DIR to $backup_dir"
  mv "$DOTFILES_DIR" "$backup_dir"
}

install_with_git() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Updating existing repo at $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only
    return
  fi

  backup_existing_dotfiles_dir
  log "Cloning $DOTFILES_REPO_URL to $DOTFILES_DIR"
  git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
}

install_with_tarball() {
  backup_existing_dotfiles_dir
  mkdir -p "$DOTFILES_DIR"

  log "Downloading $DOTFILES_TARBALL_URL to $DOTFILES_DIR"
  curl -fsSL "$DOTFILES_TARBALL_URL" | tar -xz --strip-components=1 -C "$DOTFILES_DIR"
}

if command -v git >/dev/null 2>&1; then
  install_with_git
else
  install_with_tarball
fi

chmod +x "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR"/scripts/*.sh 2>/dev/null || true

log "Running dotfiles installer"
exec "$DOTFILES_DIR/install.sh"
