#!/usr/bin/env bash

for opener in browser xdg-open; do
	if command -v $opener >/dev/null 2>&1; then
		alias open="$opener";
		break;
	fi
done

colorflag=""
if ls --color > /dev/null 2>&1; then
    colorflag="--color=auto"
fi

alias ls="command ls ${colorflag}"
alias grep='command grep --color=auto '

alias listen="command lsof -P -i -n"
alias lports='command netstat -tulanp'
alias intercept="sudo strace -ff -e trace=write -e write=1,2 -p" 

alias localip="sudo /sbin/ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ips="sudo /sbin/ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias pubip="dig +short myip.opendns.com @resolver1.opendns.com"

alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# ssh to hosts
alias ctrlc='ssh -t ctrl-c.club "tmux a || tmux"'
alias europa='ssh europa.fapyd.unr.edu.ar'
