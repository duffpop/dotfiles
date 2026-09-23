#!/usr/bin/env bash
# Set up a new (or existing) macOS / Ubuntu machine from this repo:
#
#   curl -fsSL https://raw.githubusercontent.com/duffpop/dotfiles/main/bootstrap.sh | bash
#
# Idempotent: re-running only does what's missing.
set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/duffpop/dotfiles.git}"
DOTFILES="$HOME/dev/dotfiles"
OS="$(uname -s)"

log() { printf '\n==> %s\n' "$*"; }

# Move a pre-existing file out of the way (once), keeping it as <file>.<suffix>.
set_aside() { # set_aside <suffix> <sudo|""> <paths...>
  local suffix="$1" sudo="$2" f
  shift 2
  for f in "$@"; do
    if [ -e "$f" ] && [ ! -L "$f" ] && [ ! -e "$f.$suffix" ]; then
      echo "moving $f -> $f.$suffix"
      $sudo mv "$f" "$f.$suffix"
    fi
  done
}

# 1. Prerequisites: git + curl
if [ "$OS" = Darwin ]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools (finish the dialog, then re-run this script)"
    xcode-select --install
    exit 0
  fi
  if [ ! -x /opt/homebrew/bin/brew ]; then
    log "Installing Homebrew (nix-darwin drives it for casks + App Store apps)"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  log "Installing base packages"
  sudo apt-get update
  sudo apt-get install -y git curl xz-utils
fi

# 2. Nix (Determinate installer: flakes on, survives macOS updates, clean uninstall)
if ! command -v nix >/dev/null && [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  log "Installing Nix"
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi
# shellcheck disable=SC1091
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 3. This repo
if [ ! -d "$DOTFILES/.git" ]; then
  log "Cloning $REPO -> $DOTFILES"
  mkdir -p "$(dirname "$DOTFILES")"
  git clone "$REPO" "$DOTFILES"
fi

# 4. Clear files the first switch would otherwise refuse to overwrite
log "Setting aside files now managed by the repo"
if [ "$OS" = Darwin ]; then
  # nix-darwin refuses to replace /etc files it doesn't recognise.
  set_aside before-nix-darwin sudo /etc/zshrc /etc/zshenv /etc/zprofile /etc/bashrc /etc/pam.d/sudo_local
fi
# Superseded by ~/.config/git/{config,ignore}; obsolete fish functions that
# would shadow the new `dot` command / Touch ID setup.
set_aside pre-dotfiles "" "$HOME/.gitconfig" "$HOME/.gitignore" \
  "$HOME/.config/fish/functions/dot.fish" \
  "$HOME/.config/fish/functions/tid.fish" \
  "$HOME/.config/fish/functions/touch_id_setup.fish"

# 5. Apply
log "Applying configuration (first run downloads a lot; later runs are fast)"
"$DOTFILES/bin/dot" switch

log "Done."
if [ "$OS" = Darwin ]; then
  cat <<'EOF'
Next:
  - Log out and back in so every macOS setting takes effect.
  - Run `dot drift` to compare installed Homebrew packages against the repo.
EOF
else
  cat <<'EOF'
Next:
  - Install the GUI apps: dot apps
  - Open a new terminal (bash hands over to fish).
EOF
fi
