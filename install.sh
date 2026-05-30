#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

log() {
  printf '\n==> %s\n' "$1"
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

backup_path() {
  local path="$1"

  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    return
  fi

  mkdir -p "$BACKUP_DIR"
  local relative="${path#$HOME/}"
  local backup_path="$BACKUP_DIR/$relative"
  mkdir -p "$(dirname "$backup_path")"

  log "Backing up $path to $backup_path"
  mv "$path" "$backup_path"
}

link_file() {
  local source="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$source" ]; then
    log "$dest already links to $source"
    return
  fi

  backup_path "$dest"

  log "Linking $dest -> $source"
  ln -s "$source" "$dest"
}

configure_nvm() {
  log "Configuring nvm and Node.js LTS"

  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"

  local nvm_sh
  nvm_sh="$(brew --prefix nvm)/nvm.sh"

  if [ ! -s "$nvm_sh" ]; then
    echo "nvm was not found at $nvm_sh" >&2
    return 1
  fi

  # shellcheck disable=SC1090
  . "$nvm_sh"

  nvm install --lts
  nvm alias default 'lts/*'
  nvm use default

  log "Installing global npm packages"
  npm install -g @earendil-works/pi-coding-agent pi-mcp-adapter

  local zshrc="$HOME/.zshrc"
  local marker="# >>> dotfiles nvm >>>"

  if [ ! -f "$zshrc" ] || ! grep -Fq "$marker" "$zshrc"; then
    log "Adding nvm setup to $zshrc"
    cat >> "$zshrc" <<'EOF'

# >>> dotfiles nvm >>>
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"
# <<< dotfiles nvm <<<
EOF
  fi
}

ensure_homebrew

log "Installing Homebrew bundle"
brew bundle --file "$DOTFILES_DIR/Brewfile"

configure_nvm

log "Linking Karabiner and Hammerspoon configs"
link_file "$DOTFILES_DIR/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"
link_file "$DOTFILES_DIR/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

log "Opening apps"
open -a "Karabiner-Elements" || true
open -a "Hammerspoon" || true

cat <<'EOF'

Done.

Manual macOS steps that cannot be fully automated:
1. System Settings > Privacy & Security > Accessibility
   - Enable Hammerspoon
   - Enable Karabiner-Elements / karabiner_grabber / karabiner_observer if shown
2. System Settings > Privacy & Security > Input Monitoring
   - Enable Karabiner-related entries if prompted
3. In Hammerspoon, click "Reload Config" if needed.

EOF
