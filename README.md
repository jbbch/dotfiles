# dotfiles

Bootstrap files for setting up a new Mac with Karabiner-Elements, Hammerspoon, Homebrew apps, and related developer tools.

## What's included

- `Brewfile` — Homebrew formulae, casks, VS Code extensions, and global npm packages captured from this Mac.
- `hammerspoon/init.lua` — Hammerspoon config.
- `karabiner/karabiner.json` — Karabiner-Elements config.
- `install.sh` — New Mac bootstrap script.
- `scripts/capture-current.sh` — Refresh this repo from the current machine.

## New Mac setup

Install Apple's command line tools first if needed:

```sh
xcode-select --install
```

Then clone this repo and run the installer:

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer will:

1. Install Homebrew if missing.
2. Run `brew bundle` against `Brewfile`.
3. Back up existing Karabiner/Hammerspoon config files under `~/.dotfiles-backups/`.
4. Symlink configs from this repo into the expected macOS locations.
5. Open Karabiner-Elements and Hammerspoon.

## Manual macOS permissions

macOS does not allow these security prompts to be fully automated. After running `install.sh`, check:

- System Settings > Privacy & Security > Accessibility
  - Enable Hammerspoon.
  - Enable Karabiner-Elements / `karabiner_grabber` / `karabiner_observer` if shown.
- System Settings > Privacy & Security > Input Monitoring
  - Enable Karabiner-related entries if prompted.

## Updating this repo from your current Mac

After changing your local configs or installed Homebrew apps:

```sh
cd ~/dotfiles
./scripts/capture-current.sh
git diff
git add .
git commit -m "Update dotfiles"
```

## Notes

- Existing target config files are moved to `~/.dotfiles-backups/<timestamp>/` before symlinking.
- Symlinks mean future edits to `~/.hammerspoon/init.lua` or `~/.config/karabiner/karabiner.json` update this repo directly.
