#!/bin/sh

setopt INC_APPEND_HISTORY
HISTSIZE=1000000
SAVEHIST=1000000
setopt SHARE_HISTORY


if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export PATH=$HOME/.fnm:$PATH
export STARSHIP_CONFIG=$HOME/.config/starship.toml