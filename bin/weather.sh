#!/usr/bin/env bash

#trap 'rm -f /tmp/page_weather.html' INT QUIT HUP TERM EXIT

curl=$(which curl)
wget=$(which wget)
if [ -n "$curl" ]; then
	$curl -s http://wxechesortu.com.ar/ > /tmp/page_weather.html
	#$curl -s http://cablemodem.fibertel.com.ar/bettiol/ > /tmp/page_weather.html
elif [ -n "$wget" ]; then
	$wget http://wxechesortu.com.ar/ -O /tmp/page_weather.html >/dev/null 2>&1
	#$wget http://cablemodem.fibertel.com.ar/bettiol/ -O /tmp/page_weather.html >/dev/null 2>&1
else
	touch /tmp/page_weather.html
fi

t=$(sed -n '/<td>Temperatura<\/td>/{n;p;}' /tmp/page_weather.html | awk -F '[>&]' '{print $2}')
st=$(sed -n '/<td>Sensaci.*/{n;p;}' /tmp/page_weather.html | awk -F '[>&]' '{print $2}')
h=$(sed -n '/<td>Humedad<\/td>/{n;p;}' /tmp/page_weather.html | awk -F '[>%]' '{print $2}')
p=$(sed -n '/<td>Presi/{n;p;}' /tmp/page_weather.html | awk -F '[>&]' '{print $2}')
vv=$(sed -n '/<td>Velocidad del viento (r/{n;p;}' /tmp/page_weather.html | awk -F '[>&]' '{print $2}')
dv=$(sed -n '/<td>Direcci/{n;p;}' /tmp/page_weather.html | awk -F '[>&]' '{print $2}')

printf "Temperature: %31.4sC (%sC)\n" ${t} ${st}
printf "Pressure: %44.6shPa\n" ${p}
printf "Humidity: %51.6s%%\n" ${h}
printf "Wind: %41.8skm/h (%sW)\n" ${vv} ${dv}

