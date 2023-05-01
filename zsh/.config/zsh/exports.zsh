#!/bin/sh

HISTSIZE=1000000
SAVEHIST=1000000
export PATH=$HOME/.fnm:$PATH

eval "$(fnm env)"
eval "$(pyenv init -)"