#!/usr/bin/env bash
# GUI apps + system services for Ubuntu/Debian desktops: the Linux side of the
# macOS casks in nix/darwin/homebrew.nix. CLI tools come from Nix instead.
#
#   dot apps [all|apt|flatpak|snap]     (idempotent; safe to re-run)
#
# No Linux version (use the web app or skip): Arc, Granola, Linear, Notion,
# Notion Calendar, Raycast, AltTab, Rectangle Pro, Homerow, BetterDisplay,
# AeroSpace/OmniWM, Karabiner, OrbStack/Parallels/UTM (Docker + GNOME Boxes instead).
set -euo pipefail

FLATPAKS=(
  md.obsidian.Obsidian
  io.ente.auth
  app.zen_browser.zen
  com.slack.Slack      # x86_64 only
  com.spotify.Client   # x86_64 only
  us.zoom.Zoom         # x86_64 only
  com.rtosta.zapzap    # WhatsApp (unofficial wrapper of WhatsApp Web)
  org.flameshot.Flameshot # Shottr equivalent
  net.nokyan.Resources # Stats equivalent
  org.gnome.Boxes      # UTM/Parallels equivalent
)

. /etc/os-release
DISTRO="$ID"                                   # ubuntu | debian
CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
ARCH="$(dpkg --print-architecture)"            # amd64 | arm64
KEYRINGS=/etc/apt/keyrings

log() { printf '\n==> %s\n' "$*"; }
have_pkg() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'; }

# add_repo <name> <key-url> <deb-line-with-KEYRING-placeholder> [dearmor] [keyring-path]
# Keyring paths default to $KEYRINGS/<name>.gpg; pass the vendor's own path where
# its package post-install script writes the same source (else apt sees a conflict).
add_repo() {
  local name="$1" key_url="$2" line="$3" dearmor="${4:-}" keyring="${5:-$KEYRINGS/$1.gpg}"
  [ -f "/etc/apt/sources.list.d/$name.list" ] && return 0
  if [ -n "$dearmor" ]; then
    curl -fsSL "$key_url" | sudo gpg --batch --yes --dearmor -o "$keyring"
  else
    sudo curl -fsSL "$key_url" -o "$keyring"
  fi
  sudo chmod a+r "$keyring"
  echo "${line//KEYRING/$keyring}" | sudo tee "/etc/apt/sources.list.d/$name.list" >/dev/null
}

apt_section() {
  log "apt prerequisites"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gpg wget build-essential flatpak

  log "apt repositories"
  sudo install -m 0755 -d "$KEYRINGS"
  add_repo 1password https://downloads.1password.com/linux/keys/1password.asc \
    "deb [arch=$ARCH signed-by=KEYRING] https://downloads.1password.com/linux/debian/$ARCH beta main" \
    dearmor /usr/share/keyrings/1password-archive-keyring.gpg
  add_repo tailscale "https://pkgs.tailscale.com/stable/$DISTRO/$CODENAME.noarmor.gpg" \
    "deb [signed-by=KEYRING] https://pkgs.tailscale.com/stable/$DISTRO $CODENAME main"
  add_repo docker "https://download.docker.com/linux/$DISTRO/gpg" \
    "deb [arch=$ARCH signed-by=KEYRING] https://download.docker.com/linux/$DISTRO $CODENAME stable" dearmor
  # Same file name + keyring the code-insiders package itself writes.
  if [ ! -f /etc/apt/sources.list.d/vscode.sources ] && [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/microsoft.gpg
    printf '%s\n' 'Types: deb' 'URIs: https://packages.microsoft.com/repos/code' 'Suites: stable' \
      'Components: main' 'Architectures: amd64,arm64,armhf' 'Signed-By: /usr/share/keyrings/microsoft.gpg' |
      sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null
  fi
  add_repo google-cloud-sdk https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    "deb [signed-by=KEYRING] https://packages.cloud.google.com/apt cloud-sdk main" dearmor
  add_repo claude-desktop https://downloads.claude.ai/claude-desktop/key.asc \
    "deb [arch=$ARCH signed-by=KEYRING] https://downloads.claude.ai/claude-desktop/apt/stable stable main" dearmor
  add_repo warpdotdev https://releases.warp.dev/linux/keys/warp.asc \
    "deb [arch=$ARCH signed-by=KEYRING] https://releases.warp.dev/linux/deb stable main" dearmor
  add_repo helium https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc \
    "deb [arch=$ARCH signed-by=KEYRING] https://pkg.helium.computer/deb stable main" dearmor

  # 1Password verifies its packages with debsig.
  if [ ! -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg ]; then
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22 /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol |
      sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc |
      sudo gpg --batch --yes --dearmor -o /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
  fi

  log "apt packages"
  local pkgs=(
    1password-cli tailscale code-insiders google-cloud-cli claude-desktop warp-terminal helium-bin
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  )
  # 1Password's arm64 repo only carries the CLI; the desktop app is a tarball there.
  if [ "$ARCH" = amd64 ]; then pkgs+=(1password); fi
  sudo apt-get update
  sudo apt-get install -y "${pkgs[@]}"
  [ "$ARCH" = amd64 ] || echo "note: install the 1Password desktop app from https://downloads.1password.com/linux/tar/stable/aarch64/1password-latest.tar.gz"

  # ChatGPT (includes the Codex app): the .deb registers OpenAI's apt repo on install.
  if ! have_pkg chatgpt; then
    local deb
    deb="$(mktemp -d)/chatgpt.deb"
    curl -fsSL -o "$deb" "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_$ARCH.deb"
    sudo apt-get install -y "$deb"
  fi

  # Ghostty is in the distro archive from Ubuntu 26.04; older releases use the snap.
  if ! have_pkg ghostty && apt-cache show ghostty >/dev/null 2>&1; then
    sudo apt-get install -y ghostty
  fi

  log "system setup"
  getent group docker >/dev/null && sudo usermod -aG docker "${USER:-$(id -un)}"
  # LC_ALL=en_GB.UTF-8 is set in fish (config/fish/conf.d/env.fish).
  if ! locale -a 2>/dev/null | grep -qi '^en_GB\.utf8$'; then
    [ -f /etc/locale.gen ] && sudo sed -i 's/^# *\(en_GB.UTF-8\)/\1/' /etc/locale.gen
    sudo locale-gen en_GB.UTF-8
  fi
}

flatpak_section() {
  log "flatpak apps"
  command -v flatpak >/dev/null || sudo apt-get install -y flatpak
  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  local app
  for app in "${FLATPAKS[@]}"; do
    flatpak install --user -y --noninteractive flathub "$app" || echo "warning: $app not installed (unavailable for $(uname -m)?)" >&2
  done
}

snap_section() {
  if have_pkg ghostty; then return 0; fi
  log "snaps"
  command -v snap >/dev/null || {
    echo "warning: snapd not available; install Ghostty manually (https://ghostty.org/docs/install/binary)" >&2
    return 0
  }
  snap list ghostty >/dev/null 2>&1 || sudo snap install ghostty --classic
}

case "${1:-all}" in
all) apt_section && flatpak_section && snap_section ;;
apt) apt_section ;;
flatpak) flatpak_section ;;
snap) snap_section ;;
*)
  echo "usage: $0 [all|apt|flatpak|snap]" >&2
  exit 1
  ;;
esac

log "done. Afterwards: 'sudo tailscale up', log out/in for the docker group, open 1Password > Settings > Developer > enable SSH agent."
