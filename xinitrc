#!/usr/bin/env bash

/sbin/lsmod | grep -q nvidia && { xrandr --setprovideroutputsource modesetting NVIDIA-G0; xrandr --auto; }

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

# merge in defaults and keymaps

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	setxkbmap -option "terminate:ctrl_alt_bksp" es
    xmodmap "$usermodmap"
fi

if [ -f ~/.Xprofile ]; then
	. ~/.Xprofile
fi

exec openbox

