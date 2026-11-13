# --- Environment -------------------------------------------------------------
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx LANG en_US.UTF-8
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship/starship.toml"

# Keys created by `mise run setup`: sops age key, SSH key in the Secure Enclave (macOS 26+)
set -gx SOPS_AGE_KEY_FILE "$XDG_CONFIG_HOME/sops/age/keys.txt"
test -e /usr/lib/ssh-keychain.dylib; and set -gx SSH_SK_PROVIDER /usr/lib/ssh-keychain.dylib

# --- PATH --------------------------------------------------------------------
test -x /opt/homebrew/bin/brew; and /opt/homebrew/bin/brew shellenv fish | source
fish_add_path -g ~/.local/bin
command -q mise; and mise activate fish | source

# --- Interactive shells only -------------------------------------------------
status is-interactive; or return

# Plugins: fisher installs itself once, then what fish_plugins lists
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    and fisher update
end
fish_config theme choose "Rosé Pine Auto"

# Prompt, smarter cd, completions
command -q starship; and starship init fish | source
command -q zoxide; and zoxide init fish | source
command -q carapace; and carapace _carapace fish | source

# Aliases: all of them here, one per line
alias k kubectl
alias vi nvim
alias vim nvim

# One tmux session: created by the first terminal, taken over by the next ones
if not set -q TMUX; and command -q tmux
    exec tmux new-session -A -D -s main
end
