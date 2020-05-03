#!/usr/bin/env bash

[ -x /usr/bin/lesspipe ] && export LESSOPEN="|lesspipe %s"

export VDPAU_DRIVER=va_gl
export LIBVA_DRIVER_NAME=vdpau
export PATH=$HOME/.bin:$PATH
export PATH=$PATH:~/.local/bin
export EDITOR=vim
export MANPAGER="less -X"
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF8
export LANG=en_US.UTF-8
export ALSA_CHANNEL=Master
export MUSIC_SYNC_DIR="$HOME/Music"
