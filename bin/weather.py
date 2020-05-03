#!/usr/bin/python3

import os
import sys
import datetime
import json
import urllib.request
import urllib.parse
import importlib.util

spec = importlib.util.spec_from_file_location("weather config", os.environ['HOME'] + '/.profile.d/openweather.py')
config = importlib.util.module_from_spec(spec)
spec.loader.exec_module(config)

api_prefix = 'https://api.openweathermap.org/data/2.5/'
api_key = config.API_KEY
city_id = config.CITY_ID
try:
    unit = config.UNIT
except:
    unit = 'metric'
try:
    max_forecast = config.max_forecast
except:
    max_forecast = 3

def day_string(str_date):
    dayl = ['mon','tue','wed','thu','fri','sat','sun']
    year, month, day = (int(x) for x in str_date.split('-')) 
    return dayl[datetime.datetime(year, month, day).weekday()]

def update_data():
    api_forecast = api_prefix + 'forecast?appid={}&id={}&units={}'.format(api_key, city_id, unit)
    api_weather = api_prefix + 'weather?appid={}&id={}&units={}'.format(api_key, city_id, unit)

    try:
        os.mkdir(os.environ['HOME'] + '/.cache/weather', mode=0o750)
    except FileExistsError:
        pass

    with open(os.environ['HOME'] + '/.cache/weather/weather.json.tmp', 'w+') as w:
        f = urllib.request.urlopen(api_weather)
        w.write(f.read().decode('utf-8'))
    os.rename(os.environ['HOME'] + '/.cache/weather/weather.json.tmp', os.environ['HOME'] + '/.cache/weather/weather.json')

    f = urllib.request.urlopen(api_forecast)
    s = json.load(f)
    if s['cod'] != '200':
        print('return was not 200')
        return false

    forecast = []
    forecast.append({ 'min' : round(s['list'][1]['main']['temp_min']), 'max' : round(s['list'][1]['main']['temp_max']), 'day' : day_string(s['list'][1]['dt_txt'].split(' ')[0]), 'icon' : s['list'][1]['weather'][0]['id'], 'date' : s['list'][1]['dt_txt'].split(' ')[0] })
    idx = 0
    for item in s['list'][1::]:
        if item['dt_txt'].split(' ')[0] == forecast[idx]['date']:
            forecast[idx]['min'] = round(min(item['main']['temp_min'], forecast[idx]['min']))
            forecast[idx]['max'] = round(max(item['main']['temp_max'], forecast[idx]['max']))
            forecast[idx]['icon'] = max(item['weather'][0]['id'], forecast[idx]['icon'])
        else:
            idx += 1
            if idx == max_forecast:
                break
            forecast.append({ 'min' : round(item['main']['temp_min']), 'max' : round(item['main']['temp_max']), 'icon' : item['weather'][0]['id'], 'day' : day_string(item['dt_txt'].split(' ')[0]), 'date' : item['dt_txt'].split(' ')[0] })

    with open(os.environ['HOME'] + '/.cache/weather/forecast.json.tmp', 'w+') as w:
        w.write(json.dumps({ 'forecast' : forecast }))
    os.rename(os.environ['HOME'] + '/.cache/weather/forecast.json.tmp', os.environ['HOME'] + '/.cache/weather/forecast.json')

def get_item(fname, opt):
    with open(fname, 'r') as f:
        cur = json.load(f)
        for item in opt:
            if type(cur) == list:
                cur = cur[int(item)]
            else:
                cur = cur.get(item)
    try:
        return round(float(cur))
    except ValueError:
        return cur

def get_forecast(opt):
    print(get_item(os.environ['HOME'] + '/.cache/weather/forecast.json', opt))

def get_weather(opt):
    print(get_item(os.environ['HOME'] + '/.cache/weather/weather.json', opt))

def say_help(name):
    print("""
usage {} <opt>

opt:
    update - update forecast and current weather
    get <weather|forecast> field[s]
""".format(name))
    sys.exit(1)

if len(sys.argv) == 1:
    say_help(sys.argv[0])

if sys.argv[1] == 'update':

    update_data()
elif sys.argv[1] == 'get':
    if sys.argv[2] == 'weather':
        get_weather(sys.argv[3::])
    elif sys.argv[2] == 'forecast':
        get_forecast(sys.argv[3::])
    else:
        say_help(sys.argv[0])
else:
    say_help(sys.argv[0])
