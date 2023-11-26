#!/usr/bin/env bash

encrypt()
{
	if [ -e "${1}.crypt" ]; then
		tput setaf 1
		echo "* ERROR * ${1}.crypt already exists. Exiting..."
		tput sgr0
		return 1
	fi

	i=0
	while read line; do
	items+=("$i" "$line")
		i=$(($i + 1))
	done < <(gpg --list-keys | grep @ | sed -e 's/uid[ ]*\[.*\] //g')
	i=$(LC_ALL=en_US dialog --stdout --backtitle "Encryption made easy" \
		--title Encrypt --menu "Pick the recipient" $(($i + 7)) 76 $i "${items[@]}")
	if [ $? -ne 0 ]; then
		return 0
	fi
	recp=$(echo "${items[$(($i + 1))]}" | awk -F '[<>]' '{print $(NF-1)}')

	gpg --output "${1}.crypt" --encrypt --recipient ${recp} "${1}"
}

decrypt()
{
	out=$(basename "$1" .crypt)
	if [ "${out}" = "$1" ]; then
		out=$(LC_ALL=en_US dialog --stdout --backtitle "Encryption made easy" \
			--title Decrypt --inputbox "Type the output filename" 8 40)
		if [ $? -ne 0 -o -z "$out" ]; then
			return 0
		fi
	fi
	gpg --output "${out}" --decrypt "${1}"
}

json() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript
	else # pipe
		python -mjson.tool | pygmentize -l javascript
	fi
}

# Start an HTTP server from a directory, optionally specifying the port
serve() {
	local port="${1:-8000}"
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python3 -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

man() {
	env \
		LESS_TERMCAP_mb="$(printf '\e[1;31m')" \
		LESS_TERMCAP_md="$(printf '\e[1;31m')" \
		LESS_TERMCAP_me="$(printf '\e[0m')" \
		LESS_TERMCAP_se="$(printf '\e[0m')" \
		LESS_TERMCAP_so="$(printf '\e[1;44;33m')" \
		LESS_TERMCAP_ue="$(printf '\e[0m')" \
		LESS_TERMCAP_us="$(printf '\e[1;32m')" \
		man "$@"
}

ps() {
	if [ "${1}" = 'axf' ]; then
		command ps --ppid 2 -p 2 --deselect f
	else
		command ps $*
	fi
}

git_find_large_files() {
    git rev-list --objects --all \
        | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
        | sed -n 's/^blob //p' \
        | sort --numeric-sort --key=2 \
        | cut -c 1-12,41- \
        | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}
