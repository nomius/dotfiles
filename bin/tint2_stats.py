#!/usr/bin/env python3

import os
import math
import multiprocessing

import socket, struct
from ping3 import ping

def root_usage():
    disk = os.statvfs("/")
    capacity = disk.f_bsize * disk.f_blocks
    used = disk.f_bsize * (disk.f_blocks - disk.f_bavail) 

    capacity_show = math.ceil(capacity/(1024*1024*1024))
    percentaje_used = math.ceil(used*100/capacity)

    return "/ " + str(capacity_show) + " (" + str(percentaje_used) + "%)"

def cores():
    return str(multiprocessing.cpu_count()) + " cores"

def memmory():
    meminfo = dict((i.split()[0].rstrip(':'), int(i.split()[1])) for i in open('/proc/meminfo').readlines())
    used = meminfo['MemTotal'] - meminfo['MemFree'] - meminfo['Cached']
    percentaje_used = (used*100)/meminfo['MemTotal']

    return 'Mem: %.2f GB (%d%%)' % (used/(1024*1024), math.ceil(percentaje_used))

def wireless():
    with open("/proc/net/wireless") as f:
        for line in f.readlines():
            if ":" in line:
                lines = list(filter(None, line.split(" ")))
                return lines[0] + " " + str(math.ceil(float(lines[2] + "0")*100/70)) + "%"

def latency_to_gateway():
    try:
        with open("/proc/net/route") as f:
            for line in f:
                fields = line.strip().split()
                if fields[1] != '00000000' or not int(fields[3], 16) & 2:
                    continue
                gateway = socket.inet_ntoa(struct.pack("<L", int(fields[2], 16)))
                return str(math.ceil(ping(gateway).real * 1000))
    except:
        pass
    return None


root = root_usage()
cores = cores()
memory = memmory()
wireless = wireless()
latency = latency_to_gateway()
if not latency:
    latency = '<span foreground="#faa">(timeout)  </span> | '
else:
    latency = '<span foreground="#7af">(' + latency + ' ms)</span> | '

print(' <span foreground="#ffaaaa">' + root + "</span> | " + '<span foreground="#aaffaa">' + cores + "</span> | " + '<span foreground="#ffffaa">' + memory + "</span> | " + '<span foreground="#ffffdd">' + wireless + "</span> | " + latency)
