#!/bin/sh

setopt INC_APPEND_HISTORY
HISTSIZE=1000000
SAVEHIST=1000000
setopt SHARE_HISTORY


eval "$(fnm env)"
eval "$(pyenv init -)"

export PATH=$HOME/.fnm:$PATH
