#!/usr/bin/env bash

. /etc/profile

for f in ~/.profile.d/*.sh; do
	[ -x "${f}" ] && . "${f}"
done

