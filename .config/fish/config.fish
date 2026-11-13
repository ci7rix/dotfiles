# Install fisher, then the plugins listed in fish_plugins
if status is-interactive; and not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    and fisher update
end

# Homebrew
if command -v brew >/dev/null 2>&1
    eval (brew shellenv)
else if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else
    echo "[WARN] Homebrew not found" >&2
end

# Path
fish_add_path ~/.local/bin

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"

# Locale
set -gx LC_ALL en_US.UTF-8

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

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
if command -v starship >/dev/null 2>&1
    starship init fish | source
else
    echo "[WARN] Starship not found" >&2
end

if status is-interactive
    fish_config theme choose "Rosé Pine Auto"

    # Neovim everywhere, whatever is typed
    alias vi nvim
    alias vim nvim

    if not set -q TMUX; and command -v tmux >/dev/null 2>&1
        exec tmux new-session -A -D -s main
    end
end
