#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$DOTFILES_DIR/hammerspoon" "$DOTFILES_DIR/karabiner"

cp "$HOME/.hammerspoon/init.lua" "$DOTFILES_DIR/hammerspoon/init.lua"
cp "$HOME/.config/karabiner/karabiner.json" "$DOTFILES_DIR/karabiner/karabiner.json"

if command -v brew >/dev/null 2>&1; then
  brew bundle dump --file "$DOTFILES_DIR/Brewfile" --force
fi

printf 'Captured current configs into %s\n' "$DOTFILES_DIR"
