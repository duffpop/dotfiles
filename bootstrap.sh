#!/usr/bin/env bash
# Set up a new (or existing) macOS / Ubuntu machine from this repo:
#
#   curl -fsSL https://raw.githubusercontent.com/duffpop/dotfiles/main/bootstrap.sh | bash
#
# Idempotent: re-running only does what's missing. A failing step doesn't stop
# the run: later steps that don't depend on it still run, and a summary (plus
# the full log path) is printed at the end. Must work with macOS /bin/bash 3.2.
set -uo pipefail

REPO="${DOTFILES_REPO:-https://github.com/duffpop/dotfiles.git}"
DOTFILES="$HOME/dev/dotfiles"
OS="$(uname -s)"
STATE="$HOME/.local/state/dotfiles"
LOG="$STATE/bootstrap-$(date +%Y%m%d-%H%M%S).log"
WARNINGS="$STATE/switch-warnings.log" # written by `dot switch`

log() { printf '\n==> %s\n' "$*"; }

OK=()
FAILED=()
SKIPPED=()

# step <label> <function> [needs-label...]: run <function> with errexit in a
# subshell and record the outcome; skip it if a step it needs didn't succeed.
step() {
  local label="$1" fn="$2" need
  shift 2
  for need in "$@"; do
    if ! printf '%s\n' "${OK[@]+"${OK[@]}"}" | grep -qxF "$need"; then
      log "Skipping: $label (needs: $need)"
      SKIPPED+=("$label (needs: $need)")
      return 1
    fi
  done
  log "$label"
  (
    set -e
    "$fn"
  )
  local rc=$?
  if [ "$rc" -eq 0 ]; then
    OK+=("$label")
  else
    echo "!! $label failed (exit $rc); continuing" >&2
    FAILED+=("$label")
  fi
  return "$rc"
}

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

# --- steps ------------------------------------------------------------------

sudo_access() {
  # Ask once, up front, and keep sudo alive for the whole run: Homebrew's
  # non-interactive installer, Nix and nix-darwin all need it, and the first
  # run outlasts sudo's 5-minute timeout. sudo reads the password from the
  # terminal, so this works under `curl | bash`.
  sudo -v
}

prerequisites() {
  if [ "$OS" = Darwin ]; then
    if [ ! -x /opt/homebrew/bin/brew ]; then
      # Also installs the Xcode Command Line Tools (git) without a GUI dialog.
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! xcode-select -p >/dev/null 2>&1; then
      echo "Installing Xcode Command Line Tools: finish the dialog; this script waits"
      xcode-select --install || true
      until xcode-select -p >/dev/null 2>&1; do sleep 5; done
    fi
  else
    sudo apt-get update
    sudo apt-get install -y git curl xz-utils
  fi
}

install_nix() {
  # Determinate installer: flakes on, survives macOS updates, clean uninstall.
  if ! command -v nix >/dev/null && [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
  fi
}

clone_repo() {
  if [ ! -d "$DOTFILES/.git" ]; then
    mkdir -p "$(dirname "$DOTFILES")"
    git clone "$REPO" "$DOTFILES"
  fi
}

set_aside_files() {
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
}

apply_config() {
  DOTFILES_BOOTSTRAP=1 "$DOTFILES/bin/dot" switch
}

summary() {
  local s
  log "Summary"
  for s in "${OK[@]+"${OK[@]}"}"; do echo "  ok       $s"; done
  for s in "${FAILED[@]+"${FAILED[@]}"}"; do echo "  FAILED   $s"; done
  for s in "${SKIPPED[@]+"${SKIPPED[@]}"}"; do echo "  skipped  $s"; done
  if [ -s "$WARNINGS" ]; then
    log "Applied with warnings (things to fix by hand, then run 'dot'):"
    cat "$WARNINGS"
  fi
  echo
  echo "Full log: $LOG"
  if [ "${#FAILED[@]}" -gt 0 ] || [ "${#SKIPPED[@]}" -gt 0 ]; then
    echo "Fix the failed step (see the log), then re-run the same command; finished steps are skipped."
    return 1
  fi
  if [ "$OS" = Darwin ]; then
    printf '%s\n' "Next:" \
      "  - Log out and back in so every macOS setting takes effect." \
      "  - Run 'dot drift' to compare installed Homebrew packages against the repo."
  else
    printf '%s\n' "Next:" \
      "  - Install the GUI apps: dot apps" \
      "  - Open a new terminal (bash hands over to fish)."
  fi
}

# The body is a function so bash reads the whole script before running it:
# under `curl | bash` any step that reads stdin would otherwise eat the rest.
main() {
  # (not `step ... || ...`: bash ignores errexit inside anything run from a condition)
  step "Administrator access" sudo_access
  if [ "${#FAILED[@]}" -gt 0 ]; then
    summary
    return 1
  fi
  # Keep sudo alive. Its output must not hold the `| tee` pipe open, or the
  # script would never exit.
  while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" || exit
  done </dev/null >/dev/null 2>&1 &
  local keepalive=$!
  local prereq="Command Line Tools + Homebrew"
  [ "$OS" = Darwin ] || prereq="Base packages (git, curl)"
  step "$prereq" prerequisites
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

  step "Install Nix" install_nix
  # shellcheck disable=SC1091
  [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] &&
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  step "Clone $REPO" clone_repo "$prereq"
  step "Set aside files now managed by the repo" set_aside_files
  step "Apply configuration (first run downloads a lot)" apply_config \
    "$prereq" "Install Nix" "Clone $REPO"

  summary
  local rc=$?
  kill "$keepalive" 2>/dev/null
  return "$rc"
}

mkdir -p "$STATE"
main "$@" 2>&1 | tee "$LOG"
exit "${PIPESTATUS[0]}"
