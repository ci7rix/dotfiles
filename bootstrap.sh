#!/usr/bin/env bash
# Set up a new or freshly reset Mac from this repository:
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/ci7rix/dotfiles/main/bootstrap.sh)"
#
# 1. Xcode Command Line Tools (git), without the installer window
# 2. mise, in ~/.local/bin
# 3. mise bootstrap: clone this repo, link ~/.config/mise into it, apply everything
# 4. mise run setup: Touch ID for sudo, SSH key, sops age key
#
# Safe to run again. Extra arguments go to `mise bootstrap` (e.g. --dry-run).
set -euo pipefail

REPO_URL="https://github.com/ci7rix/dotfiles"
REPO_DIR="$HOME/Developer/github.com/ci7rix/dotfiles"   # = dotfiles.root in mise.toml (mise run check compares them)
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || die "This script is for macOS."

# Ask for the password once, and keep sudo alive while this script runs
step "Administrator password"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done >/dev/null 2>&1 &

# --- 1. Xcode Command Line Tools ------------------------------------------------
step "Xcode Command Line Tools"
clt_installed() {
  local dir
  dir="$(xcode-select -p 2>/dev/null)" && [ -x "$dir/usr/bin/git" ]
}

if ! clt_installed; then
  # This marker makes softwareupdate list the Command Line Tools
  marker=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch "$marker"
  label="$(softwareupdate --list 2>/dev/null \
    | sed -n 's/^.*Label: \(Command Line Tools for Xcode-.*\)$/\1/p' | tail -n 1)"
  if [ -n "$label" ]; then sudo softwareupdate --install "$label" --verbose; fi
  rm -f "$marker"
fi
if ! clt_installed; then
  echo "softwareupdate did not install them: finish the installer window that opens."
  xcode-select --install 2>/dev/null || true
  until clt_installed; do sleep 5; done
fi

# --- 2. mise --------------------------------------------------------------------
step "mise"
command -v mise >/dev/null || curl -fsSL https://mise.run | sh
mise --version

# --- 3. Clone this repo and apply it --------------------------------------------
step "mise bootstrap from $REPO_URL into $REPO_DIR"
mkdir -p "$(dirname "$REPO_DIR")"
mise bootstrap --from "$REPO_URL" --from-dir "$REPO_DIR" --config-dir .config/mise --yes "$@"

# --- 4. This Mac only -----------------------------------------------------------
case " $* " in *" --dry-run "*) echo "Dry run: setup skipped."; exit 0 ;; esac
step "mise run setup"
cd "$REPO_DIR"
mise trust
mise run setup || echo "Some steps failed: fix them, then run 'mise run setup' again."

step "Done. Log out and back in (fish becomes the login shell), then see the README."
