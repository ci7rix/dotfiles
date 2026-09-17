# Homebrew — doit être en premier, avant tout ce qui en dépend
if command -v brew >/dev/null 2>&1
    eval (brew shellenv)
else if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else
    echo "[WARN] Homebrew not found" >&2
end

# Homebrew — doit être en premier, avant tout ce qui en dépend
if command -v brew >/dev/null 2>&1
    eval (brew shellenv)
else if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else
    echo "[WARN] Homebrew not found" >&2
end

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$XDG_CONFIG_HOME/local/share"
set -gx XDG_CACHE_HOME "$XDG_CONFIG_HOME/cache"

# Locale
set -gx LC_ALL en_US.UTF-8

# Editor
set -gx EDITOR vim
set -gx VISUAL vim

# Mise
if command -v mise >/dev/null 2>&1
    mise activate fish | source
else
    echo "[WARN] Mise not found" >&2
end

# Zoxide
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
else
    echo "[WARN] Zoxide not found" >&2
end

# Carapace
if command -v carapace >/dev/null 2>&1
    carapace _carapace fish | source
else
    echo "[WARN] Carapace not found" >&2
end

# Starship
set -gx STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
starship init fish | source

fish_config theme choose "Rosé Pine Auto"

if status is-interactive; and not set -q TMUX
    exec tmux new-session -A -D -s main
end