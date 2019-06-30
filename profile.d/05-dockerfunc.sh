#!/bin/bash
# Bash wrappers for docker run commands

export DOCKER_REPO_PREFIX=jess

#
# Helper Functions
#
dcleanup(){
	local containers
	mapfile -t containers < <(docker ps -aq 2>/dev/null)
	docker rm "${containers[@]}" 2>/dev/null
	local volumes
	mapfile -t volumes < <(docker ps --filter status=exited -q 2>/dev/null)
	docker rm -v "${volumes[@]}" 2>/dev/null
	local images
	mapfile -t images < <(docker images --filter dangling=true -q 2>/dev/null)
	docker rmi "${images[@]}" 2>/dev/null
}
hostcleanup() {
	for f in $(declare -f | grep hostess | sed -e 's/.*hostess add[[:blank:]]\+\([a-zA-z0-9_\$"]\+\)[[:blank:]]*.*/\1/g' | grep -v '\$'); do
		[ "$(docker inspect --format "{{.State.Running}}" $f 2>/dev/null)" == "false" ] && sudo hostess rm $f && echo $f removed
	done
}
del_stopped(){
	local name=$1
	[ -z "${name}" ] && return 1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm "$name"
	fi
}
rmctr(){
	# shellcheck disable=SC2068
	docker rm -f $@ 2>/dev/null || true
}
relies_on(){
	for container in "$@"; do
		local state
		state=$(docker inspect --format "{{.State.Running}}" "$container" 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$container is not running, starting it for you."
			$container
		fi
	done
}
# creates an nginx config for a local route
nginx_config(){
	server=$1
	route=$2

	[ -z "${server}" -o -z "${server}" ] && return 1
	mkdir -p ${HOME}/.nginx/conf.d
	cat >"${HOME}/.nginx/conf.d/${server}.conf" <<-EOF
	upstream ${server} { server ${route}; }
	server {
	server_name ${server};

	location / {
	proxy_pass  http://${server};
	proxy_http_version 1.1;
	proxy_set_header Upgrade \$http_upgrade;
	proxy_set_header Connection "upgrade";
	proxy_set_header Host \$http_host;
	proxy_set_header X-Forwarded-Proto \$scheme;
	proxy_set_header X-Forwarded-For \$remote_addr;
	proxy_set_header X-Forwarded-Port \$server_port;
	proxy_set_header X-Request-Start \$msec;
}
	}
	EOF

	# restart nginx
	docker restart nginx

	# add host to /etc/hosts
	sudo hostess add "$server" 127.0.0.1

	# open browser
	browser "http://${server}"
}
daws(){
	docker run -it --rm \
		-v "${HOME}/.aws:/root/.aws" \
		--log-driver none \
		--name aws \
		${DOCKER_REPO_PREFIX}/awscli "$@"
}
daz(){
	docker run -it --rm \
		-v "${HOME}/.azure:/root/.azure" \
		--log-driver none \
		${DOCKER_REPO_PREFIX}/azure-cli "$@"
}
dgcloud(){
	docker run --rm -it \
		-v "${HOME}/.gcloud:/root/.config/gcloud" \
		-v "${HOME}/.ssh:/root/.ssh:ro" \
		-v "$(which docker):/usr/bin/docker" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--name gcloud \
		${DOCKER_REPO_PREFIX}/gcloud "$@"
}

dcadvisor(){
	docker run -d \
		--restart always \
		-v /:/rootfs:ro \
		-v /var/run:/var/run:rw \
		-v /sys:/sys:ro  \
		-v /var/lib/docker/:/var/lib/docker:ro \
		-p 1234:8080 \
		--name cadvisor \
		google/cadvisor

	sudo hostess add cadvisor "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' cadvisor)"
	browser "http://cadvisor:8080"
}
dchrome(){
	# add flags for proxy if passed
	local proxy=
	local map
	local args=$*
	if [[ "$1" == "tor" ]]; then
		relies_on torproxy

		map="MAP * ~NOTFOUND , EXCLUDE torproxy"
		proxy="socks5://torproxy:9050"
		args="https://check.torproject.org/api/ip ${*:2}"
	fi

	del_stopped chrome

	# one day remove /etc/hosts bind mount when effing
	# overlay support inotify, such bullshit
	docker run -d \
		--memory 3gb \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/Downloads:/root/Downloads" \
		-v "${HOME}/Pictures:/root/Pictures" \
		-v "${HOME}/Torrents:/root/Torrents" \
		-v "${HOME}/.chrome:/data" \
		-v /dev/shm:/dev/shm \
		-v /etc/hosts:/etc/hosts \
		--security-opt seccomp:/etc/docker/seccomp/chrome.json \
		--device /dev/snd \
		--device /dev/dri \
		--device /dev/video0 \
		--device /dev/usb \
		--device /dev/bus/usb \
		--group-add audio \
		--group-add video \
		--name chrome \
		${DOCKER_REPO_PREFIX}/chrome --user-data-dir=/data \
		--proxy-server="$proxy" \
		--host-resolver-rules="$map" "$args"

}
dfirefox(){
	del_stopped firefox
	relies_on pulseaudio

	docker run -d \
		--memory 2gb \
		--cpuset-cpus 0 \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "${HOME}/.firefox/cache:/root/.cache/mozilla" \
		-v "${HOME}/.firefox/mozilla:/root/.mozilla" \
		-v "${HOME}/Downloads:/root/Downloads" \
		-v "${HOME}/Pictures:/root/Pictures" \
		-v "${HOME}/Torrents:/root/Torrents" \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--device /dev/snd \
		--device /dev/dri \
		--name firefox \
		${DOCKER_REPO_PREFIX}/firefox "$@"
}
dgimp(){
	del_stopped gimp

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/Pictures:/root/Pictures" \
		-v "${HOME}/.gtkrc:/root/.gtkrc" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--name gimp \
		${DOCKER_REPO_PREFIX}/gimp
}
dhollywood(){
	docker run --rm -it \
		--name hollywood \
		${DOCKER_REPO_PREFIX}/hollywood
}
dhtop(){
	docker run --rm -it \
		--pid host \
		--net none \
		--name htop \
		${DOCKER_REPO_PREFIX}/htop
}
dhtpasswd(){
	docker run --rm -it \
		--net none \
		--name htpasswd \
		--log-driver none \
		${DOCKER_REPO_PREFIX}/htpasswd "$@"
}
dhttp(){
	docker run -t --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--log-driver none \
		${DOCKER_REPO_PREFIX}/httpie "$@"
}
dirssi() {
	del_stopped irssi

	docker run --rm -it \
		--user root \
		-v "${HOME}/.irssi:/home/user/.irssi" \
		${DOCKER_REPO_PREFIX}/irssi \
		chown -R user /home/user/.irssi

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/.irssi:/home/user/.irssi" \
		--read-only \
		--name irssi \
		${DOCKER_REPO_PREFIX}/irssi
}
djohn(){
	local file
	[ -z "${file}" ] && return 1
	file=$(realpath "$1")

	docker run --rm -it \
		-v "${file}:/root/$(basename "${file}")" \
		${DOCKER_REPO_PREFIX}/john "$@"
}
dkvm(){
	del_stopped kvm
	relies_on pulseaudio

	# modprobe the module
	modprobe kvm

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /run/libvirt:/var/run/libvirt \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--name kvm \
		--privileged \
		${DOCKER_REPO_PREFIX}/kvm
}
dlibreoffice(){
	del_stopped libreoffice

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/slides:/root/slides" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--name libreoffice \
		${DOCKER_REPO_PREFIX}/libreoffice
}
dmasscan(){
	docker run -it --rm \
		--log-driver none \
		--net host \
		--cap-add NET_ADMIN \
		--name masscan \
		${DOCKER_REPO_PREFIX}/masscan "$@"
}
dnes(){
	del_stopped nes
	local game=$1
	[ -z "${game}" ] && return 1

	docker run -d \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/dri \
		--device /dev/snd \
		--name nes \
		${DOCKER_REPO_PREFIX}/nes "/games/${game}.rom"
}
dnetcat(){
	docker run --rm -it \
		--net host \
		${DOCKER_REPO_PREFIX}/netcat "$@"
}
dnginx(){
	del_stopped nginx

	docker run -d \
		--restart always \
		-v "${HOME}/.nginx:/etc/nginx" \
		--net host \
		--name nginx \
		nginx

	# add domain to hosts & open nginx
	sudo hostess add jess 127.0.0.1
}
dnmap(){
	docker run --rm -it \
		--net host \
		${DOCKER_REPO_PREFIX}/nmap "$@"
}
dpandoc(){
	local file=${*: -1}
	local lfile
	lfile=$(readlink -m "$(pwd)/${file}")
	local rfile
	rfile=$(readlink -m "/$(basename "$file")")
	local args=${*:1:${#@}-1}

	docker run --rm \
		-v "${lfile}:${rfile}" \
		-v /tmp:/tmp \
		--name pandoc \
		${DOCKER_REPO_PREFIX}/pandoc "${args}" "${rfile}"
}
dprivoxy(){
	del_stopped privoxy
	relies_on torproxy

	docker run -d \
		--restart always \
		--link torproxy:torproxy \
		-v /etc/localtime:/etc/localtime:ro \
		-p 8118:8118 \
		--name privoxy \
		${DOCKER_REPO_PREFIX}/privoxy

	sudo hostess add privoxy "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' privoxy)"
}
dpulseaudio(){
	del_stopped pulseaudio

	docker run --rm -d \
		-p 4713:4713 \
		--device /dev/snd \
		--device /dev/bus/usb \
		-v /var/run/dbus:/var/run/dbus \
		-v /etc/localtime:/etc/localtime:ro \
		-v /etc/asound.conf:/etc/asound.conf:ro \
		--name pulseaudio \
		woahbase/alpine-pulseaudio:x86_64
}

dpavucontrol() {
	del_stopped pavucontrol
	relies_on pulseaudio

	docker run --rm \
		--device /dev/snd \
		-v /var/run/dbus:/var/run/dbus \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--name pavucontrol \
		nomius/pavucontrol
}

dremmina(){
	del_stopped remmina

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		-v "${HOME}/.remmina:/root/.remmina" \
		--name remmina \
		--net host \
		${DOCKER_REPO_PREFIX}/remmina
}
dskype(){
	del_stopped skype
	relies_on pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--security-opt seccomp:unconfined \
		--device /dev/video0 \
		--group-add video \
		--group-add audio \
		--name skype \
		${DOCKER_REPO_PREFIX}/skype
}
dssh2john(){
	local file
	[ -z "${file}" ] && return 1
	file=$(realpath "$1")

	docker run --rm -it \
		-v "${file}:/root/$(basename "${file}")" \
		--entrypoint ssh2john \
		${DOCKER_REPO_PREFIX}/john "$@"
}
dsteam(){
	del_stopped steam
	relies_on pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /etc/machine-id:/etc/machine-id:ro \
		-v /var/run/dbus:/var/run/dbus \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "${HOME}/.steam:/home/steam" \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--device /dev/dri \
		--name steam \
		${DOCKER_REPO_PREFIX}/steam
}
dtelnet(){
	docker run -it --rm \
		--log-driver none \
		${DOCKER_REPO_PREFIX}/telnet "$@"
}
dtermboy(){
	del_stopped termboy
	local game=$1
	[ -z "${game}" ] && return 1

	docker run --rm -it \
		--device /dev/snd \
		--name termboy \
		${DOCKER_REPO_PREFIX}/nes "/games/${game}.rom"
}
dterraform(){
	docker run -it --rm \
		-v "${HOME}:${HOME}:ro" \
		-v "$(pwd):/usr/src/repo" \
		-v /tmp:/tmp \
		--workdir /usr/src/repo \
		--log-driver none \
		-e GOOGLE_APPLICATION_CREDENTIALS \
		-e SSH_AUTH_SOCK \
		${DOCKER_REPO_PREFIX}/terraform "$@"
}
dtor(){
	del_stopped tor

	docker run -d \
		--net host \
		--name tor \
		${DOCKER_REPO_PREFIX}/tor

	# set up the redirect iptables rules
	sudo setup-tor-iptables

	# validate we are running through tor
	browser "https://check.torproject.org/"
}
dtorbrowser(){
	del_stopped torbrowser

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--device /dev/snd \
		--name torbrowser \
		${DOCKER_REPO_PREFIX}/tor-browser
}
dtormessenger(){
	del_stopped tormessenger

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--device /dev/snd \
		--name tormessenger \
		${DOCKER_REPO_PREFIX}/tor-messenger
}
dtorproxy(){
	del_stopped torproxy

	docker run -d \
		--restart always \
		-v /etc/localtime:/etc/localtime:ro \
		-p 9050:9050 \
		--name torproxy \
		${DOCKER_REPO_PREFIX}/tor-proxy

	sudo hostess add torproxy "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' torproxy)"
}
dtraceroute(){
	docker run --rm -it \
		--net host \
		${DOCKER_REPO_PREFIX}/traceroute "$@"
}
dtransmission(){
	del_stopped transmission

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/Torrents:/transmission/download" \
		-v "${HOME}/.transmission:/transmission/config" \
		-p 9091:9091 \
		-p 51413:51413 \
		-p 51413:51413/udp \
		--name transmission \
		${DOCKER_REPO_PREFIX}/transmission


	sudo hostess add transmission "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' transmission)"
	browser "http://transmission:9091"
}
dvirsh(){
	relies_on kvm

	docker run -it --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v /run/libvirt:/var/run/libvirt \
		--log-driver none \
		--net container:kvm \
		${DOCKER_REPO_PREFIX}/libvirt-client "$@"
}
dvirt_viewer(){
	relies_on kvm

	docker run -it --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix  \
		-e "DISPLAY=unix${DISPLAY}" \
		-v /run/libvirt:/var/run/libvirt \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--log-driver none \
		--net container:kvm \
		${DOCKER_REPO_PREFIX}/virt-viewer "$@"
}
alias virt-viewer="virt_viewer"
dvlc(){
	del_stopped vlc
	relies_on pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		-e QT_DEVICE_PIXEL_RATIO \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--group-add video \
		-v "${HOME}/Torrents:/home/vlc/Torrents" \
		--device /dev/dri \
		--name vlc \
		${DOCKER_REPO_PREFIX}/vlc
}
dwireshark(){
	del_stopped wireshark

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--cap-add NET_RAW \
		--cap-add NET_ADMIN \
		--net host \
		--name wireshark \
		${DOCKER_REPO_PREFIX}/wireshark
}
