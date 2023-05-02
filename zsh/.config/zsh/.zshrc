# Created by Zap installer
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# history
HISTFILE=~/.zsh_history

# source
plug "$HOME/.config/zsh/exports.zsh"
plug "$HOME/.config/zsh/aliases.zsh"

plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "wintermi/zsh-starship"
plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"
plug "Aloxaf/fzf-tab"

# Load aliases and bookmarks if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bm-dirs" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bm-dirs"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bm-files" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/bm-files"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.