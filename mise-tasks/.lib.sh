# Shared by every task. Sourced, never run: mise ignores names starting with ".".

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
MISE_CONFIG="$REPO_ROOT/.config/mise/mise.toml"
BACKUP_DIR="$HOME/.local/state/dotfiles/backup/$(date +%Y-%m-%d-%H%M%S)"
DRY_RUN="${usage_dry_run:-false}"

# mise and the Homebrew tools, even when the caller's PATH lacks them
export PATH="$PATH:$HOME/.local/bin:/opt/homebrew/bin"

# --- Output -------------------------------------------------------------------
step() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33mWarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# --- Running things -----------------------------------------------------------
# Run a command, or only show it with --dry-run
run() { if [ "$DRY_RUN" = "true" ]; then note "would run: $*"; else "$@"; fi; }

# A named step that may fail without stopping the task; report gives the verdict
FAILED=()
try() { local name="$1"; shift; step "$name"; "$@" || FAILED+=("$name"); }
report() {
  echo
  if [ "${#FAILED[@]}" -gt 0 ]; then
    printf '\033[1;31mFailed:\033[0m\n'; printf '  - %s\n' "${FAILED[@]}"
    return 1
  fi
  echo "Done."
}

# mise with the global config only (~/.config/mise, a link into this repo):
# run from HOME so the repo is not loaded a second time as a project
mise_global() { (cd "$HOME" && mise "$@"); }

# --- Dotfiles -----------------------------------------------------------------
# Targets of the [dotfiles] table of mise.toml, without the leading "~/"
dotfile_targets() {
  awk '/^\[dotfiles\]/ { f = 1; next } /^\[/ { f = 0 }
       f && /^"~\// { sub(/^"~\//, ""); sub(/".*/, ""); print }' "$MISE_CONFIG"
}

# Move a path to BACKUP_DIR, keeping its place under HOME. Nothing is deleted.
set_aside() {
  local rel="${1#"$HOME"/}"
  if [ "$DRY_RUN" = "true" ]; then note "would set aside: ~/$rel"; return; fi
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")" && mv "$1" "$BACKUP_DIR/$rel"
  note "set aside: ~/$rel (kept in $BACKUP_DIR)"
}

# mise never replaces a real file or folder by a link: set those aside first.
# Existing links are left alone, mise repoints them itself.
CONFLICTS=0
set_aside_conflicts() {
  local t
  while IFS= read -r t; do
    if [ -e "$HOME/$t" ] && [ ! -L "$HOME/$t" ]; then
      set_aside "$HOME/$t"; CONFLICTS=$((CONFLICTS + 1))
    fi
  done < <(dotfile_targets)
  if [ "$CONFLICTS" -eq 0 ]; then note "none"; fi
}
