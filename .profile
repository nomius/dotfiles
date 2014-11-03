
. /etc/profile

if [ "$TERM" = "rxvt-unicode" -o "$TERM" = "rxvt-unicode-256color" -o "$TERM" = "rxvt" ]; then
    export LC_CTYPE=en_US.utf8; printf "\33]701;$LC_CTYPE\007"
fi

alias listen="/usr/sbin/lsof -P -i -n" 
alias intercept="sudo strace -ff -e trace=write -e write=1,2 -p" 


export QEMU_AUDIO_DRV=alsa

