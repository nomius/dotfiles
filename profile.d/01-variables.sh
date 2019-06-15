#!/usr/bin/env bash

if [ "$TERM" = "rxvt-unicode" -o "$TERM" = "rxvt-unicode-256color" -o "$TERM" = "rxvt" ]; then
    export LC_CTYPE=en_US.utf8; printf "\33]701;$LC_CTYPE\007"
fi

[ -x /usr/bin/lesspipe ] && export LESSOPEN="|lesspipe %s"

export VDPAU_DRIVER=va_gl
export LIBVA_DRIVER_NAME=vdpau
export PATH=$HOME/.bin:$PATH
export PATH=$PATH:~/.local/bin
export EDITOR=vim
export MANPAGER="less -X";


