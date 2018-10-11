
. /etc/profile


if [ -e ~/.bash/variables ]; then
	. ~/.bash/variables
fi

if [ -e ~/.bash/aliases ]; then
	. ~/.bash/aliases
fi

if [ -e ~/.bash/functions ]; then
	. ~/.bash/functions
fi

if [ -e ~/.bash/extras ]; then
	. ~/.bash/extras
fi

if [ -e ~/.bash/custom ]; then
	. ~/.bash/custom
fi

