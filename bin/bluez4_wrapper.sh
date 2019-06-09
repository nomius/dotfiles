#!/usr/bin/env bash

prog=$0

help() {
	cat << EOF
$prog [opt] <addr> <user>
opt:
	fix-python : Fix python modules usage in bluez
	install-python-modules : Install dbus and gobject
	enable-bluetooth-sound : Enable sound in bluetooth service
	pair <addr> : Pair a new bluetooth device
	trust <addr> : Make a device trusted
	connect <addr> : Connects to a bluetooth device
	disconnect <addr> : Disconnects from a bluetooth device
	create-conf <addr> <user> : Creates an alsa configuration for a given user
EOF
}

st() {
	[ $1 -eq 0 ] && { tput setaf 2; echo "Success"; } || { tput setaf 1; echo "Fail"; }
	tput sgr0
	return $?
}

fix() {
	sed -i -e 's:import gobject as GObject:from gi.repository import GObject:g'  /usr/bin/bluez-simple-agent
	st $?
	sed -i -e 's:import gobject as GObject:from gi.repository import GObject:g'  /usr/bin/bluez-test-device
	st $?
}

install_python_modules() {
	pip install dbus-python
	st $?
	pip install PyGObject
	st $?
}

enable_sound_in_bluetooth() {
	sed -i -e 's:\[General\]:\[General\]\nEnable=Source,Sink,Headset,Gateway,Control,Socket,Media:g' /etc/bluetooth/audio.conf
	/etc/rc.d/bluetoothd restart
}

pair() {
	[ -n "$1" ] && bluez-simple-agent hci0 $1
	st $?
}

trust() {
	[ -n "$1" ] && bluez-test-device trusted $1 yes
	st $?
}

connect() {
	[ -n "$1" ] && bluez-test-audio connect $1
	st $?
}

disconnect() {
	[ -n "$1" ] && bluez-test-audio disconnect $1
	st $?
}

create_conf() {
	[ -z "$1" -o -z "$2" ] && return 1
	f=$(awk -F : "/^$2/ {print \$6\"/.asoundrc\"}" /etc/passwd)
	[ "$f" = "/.asoundrc" ] && return 1
	if grep -q $1 $f 2>/dev/null; then
		return 0
	fi
	cat << EOF > $f
pcm.bt {
   type plug
   slave {
       pcm {
           type bluetooth
           device $1
           profile "auto"
       }
   }
   hint {
       show on
       description "BT-Output $1"
   }
}
ctl.bt {
  type bluetooth
}
EOF
}

case $1 in
	'fix-python')
		fix
	;;
	'install-python-modules')
		install_python_modules
	;;
	'enable-bluetooth-sound')
		enable_sound_in_bluetooth
	;;
	'pair')
		pair $2
	;;
	'trust')
		trust $2
	;;
	'connect')
		connect $2
	;;
	'disconnect')
		disconnect $2
	;;
	'create-conf')
		create_conf $2 $3
	;;
	*)
		help
	;;
esac
