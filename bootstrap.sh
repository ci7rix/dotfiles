#!/usr/bin/env bash
# Set up a new or freshly reset Mac from this repository.
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/ci7rix/dotfiles/main/bootstrap.sh)"
#
# 1. Xcode Command Line Tools (git is part of them), installed without the GUI prompt
# 2. mise, in ~/.local/bin
# 3. mise bootstrap: clone this repo, link ~/.config/mise, apply everything
#
# Extra arguments go to `mise bootstrap` (for example --dry-run).

set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/ci7rix/dotfiles}"
MISE_BIN="$HOME/.local/bin/mise"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || die "This script is for macOS."

# Ask for the password once and keep sudo alive while this script runs
log "Administrator password needed for the Command Line Tools and the bootstrap"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done >/dev/null 2>&1 &

# --- 1. Xcode Command Line Tools ----------------------------------------
clt_installed() {
  local dir
  dir="$(xcode-select -p 2>/dev/null)" && [ -x "$dir/usr/bin/git" ]
}

if clt_installed; then
  log "Command Line Tools already installed"
else
  log "Installing the Xcode Command Line Tools (git, clang...)"
  # This marker makes softwareupdate list the Command Line Tools
  marker=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch "$marker"
  label="$(softwareupdate --list 2>/dev/null \
    | sed -n 's/^.*Label: \(Command Line Tools for Xcode-.*\)$/\1/p' | tail -n 1)"
  if [ -n "$label" ]; then
    sudo softwareupdate --install "$label" --verbose
  fi
  rm -f "$marker"

  if ! clt_installed; then
    log "softwareupdate did not install them: finish the installer window that opens"
    xcode-select --install 2>/dev/null || true
    until clt_installed; do sleep 5; done
  fi
fi

# --- 2. mise -------------------------------------------------------------
if command -v mise >/dev/null 2>&1; then
  MISE="$(command -v mise)"
elif [ -x "$MISE_BIN" ]; then
  MISE="$MISE_BIN"
else
  log "Installing mise"
  curl -fsSL https://mise.run | sh
  MISE="$MISE_BIN"
fi
log "Using $("$MISE" --version)"

# --- 3. bootstrap ----------------------------------------------------------
log "Bootstrapping from $REPO_URL"
"$MISE" bootstrap --from "$REPO_URL" --config-dir .config/mise --yes "$@"

log "Done. Log out and back in so fish becomes the login shell,"
log "then follow the after-install checklist in the README."
