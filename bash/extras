#!/usr/bin/env bash

if [ -t 1 ]; then
	if [ -f /tmp/syncAvailable ]; then
		read -p "The Android device was just plugged. Want to sync? [y/n/N]: " -N 1 ans
		if [ "${ans}" = "N" ]; then
			syncMusic cancel
		elif [ "${ans}" = "y" ]; then
			syncMusic runsync
		else
			echo
		fi
	fi
fi

