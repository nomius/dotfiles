#!/usr/bin/env bash

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

# merge in defaults and keymaps

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	setxkbmap -option "terminate:ctrl_alt_bksp"
    xmodmap "$usermodmap"
fi

if [ -f ~/.Xprofile ]; then
	. ~/.Xprofile
fi

exec openbox

