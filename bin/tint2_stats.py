#!/usr/bin/env python3

# By David B. Cortarello (Nomius/DaveC) <dcortarello@gmail.com>

import os
import math
import fcntl, sys

import socket, struct

import select, time

from pathlib import Path

# The ping class wasn't actually a class but a set of functions I borrowed 
# from somewhere I can't remember and created a class out of it for 
# encapsulation. 
# If you wrote the below "ping" code, please let me know so I can put your 
# name somewhere in the credits.

class ping:
    ICMP_ECHO_REQUEST = 8

    def checksum(self, source_string):
        """
        I'm not too confident that this is right but testing seems
        to suggest that it gives the same answers as in_cksum in ping.c
        """
        sum = 0
        countTo = (len(source_string)/2)*2
        count = 0
        while count<countTo:
            thisVal = source_string[count + 1]*256 + source_string[count]
            sum = sum + thisVal
            sum = sum & 0xffffffff # Necessary?
            count = count + 2

        if countTo<len(source_string):
            sum = sum + source_string[len(source_string) - 1]
            sum = sum & 0xffffffff # Necessary?

        sum = (sum >> 16)  +  (sum & 0xffff)
        sum = sum + (sum >> 16)
        answer = ~sum
        answer = answer & 0xffff

        # Swap bytes. Bugger me if I know why.
        answer = answer >> 8 | (answer << 8 & 0xff00)

        return answer


    def receive_one_ping(self, my_socket, ID, timeout):
        """
        receive the ping from the socket.
        """
        timeLeft = timeout
        while True:
            startedSelect = time.time()
            whatReady = select.select([my_socket], [], [], timeLeft)
            howLongInSelect = (time.time() - startedSelect)
            if whatReady[0] == []: # Timeout
                return

            timeReceived = time.time()
            recPacket, addr = my_socket.recvfrom(1024)
            icmpHeader = recPacket[20:28]
            type, code, checksum, packetID, sequence = struct.unpack(
                "bbHHh", icmpHeader
            )
            # Filters out the echo request itself.
            # This can be tested by pinging 127.0.0.1
            # You'll see your own request
            if type != 8 and packetID == ID:
                bytesInDouble = struct.calcsize("d")
                timeSent = struct.unpack("d", recPacket[28:28 + bytesInDouble])[0]
                return timeReceived - timeSent

            timeLeft = timeLeft - howLongInSelect
            if timeLeft <= 0:
                return


    def send_one_ping(self, my_socket, dest_addr, ID):
        """
        Send one ping to the given >dest_addr<.
        """
        dest_addr  =  socket.gethostbyname(dest_addr)

        # Header is type (8), code (8), checksum (16), id (16), sequence (16)
        my_checksum = 0

        # Make a dummy heder with a 0 checksum.
        header = struct.pack("bbHHh", self.ICMP_ECHO_REQUEST, 0, my_checksum, ID, 1)
        bytesInDouble = struct.calcsize("d")
        data = bytes((192 - bytesInDouble) * "Q", 'utf-8')
        data = struct.pack("d", time.time()) + data

        # Calculate the checksum on the data and the dummy header.
        my_checksum = self.checksum(header + data)

        # Now that we have the right checksum, we put that in. It's just easier
        # to make up a new header than to stuff it into the dummy.
        header = struct.pack(
            "bbHHh", self.ICMP_ECHO_REQUEST, 0, socket.htons(my_checksum), ID, 1
        )
        packet = header + data
        my_socket.sendto(packet, (dest_addr, 1)) # Don't know about the 1


    def do_one(self, dest_addr, timeout):
        """
        Returns either the delay (in seconds) or none on timeout.
        """
        icmp = socket.getprotobyname("icmp")
        try:
            my_socket = socket.socket(socket.AF_INET, socket.SOCK_RAW, icmp)
        except PermissionError as e:
            e.args = (e.args if e.args else tuple()) + ((
                " - Note that ICMP messages can only be sent from processes"
                " running as root."
            ),)
            raise

        my_ID = os.getpid() & 0xFFFF

        self.send_one_ping(my_socket, dest_addr, my_ID)
        delay = self.receive_one_ping(my_socket, my_ID, timeout)

        my_socket.close()
        return delay

    def get_ping_time(self, myaddr):
        try:
            delay = self.do_one(myaddr, 2)
        except socket.gaierror as e:
            print("failed. (socket error: '%s')" % e)
            return None

        if delay is None:
            print("failed. (timeout within %ssec.)" % timeout)
        else:
            delay = delay
        return delay

def root_usage():
    st = os.statvfs("/")
    
    free_bytes = st.f_frsize * st.f_bavail
    
    if st.f_blocks > 0:
        used_percent = ((st.f_blocks - st.f_bavail) / st.f_blocks) * 100
    else:
        used_percent = 0.0
    
    # Define binary byte constants
    ONE_MB = 1024 * 1024
    ONE_GB = 1024 * 1024 * 1024
    
    # Format percentage string
    pct_string = f" ({used_percent:.0f}%)"
    
    # Determine the format based on size and append percentage
    if free_bytes < ONE_GB:
        free_mb = free_bytes / ONE_MB
        return f"/ {free_mb:.1f} MB" + pct_string
    else:
        free_gb = free_bytes / ONE_GB
        return f"/ {free_gb:.1f} GB" + pct_string

def print_cpu_package_temp():
    hwmon_base = Path('/sys/class/hwmon')
    
    if not hwmon_base.exists():
        return

    # 1. Iterate through all hwmon device directories (e.g., hwmon0, hwmon1)
    for hwmon_dir in hwmon_base.iterdir():
        
        # 2. Search for any file matching the pattern 'temp*_label'
        for label_file in hwmon_dir.glob('temp*_label'):
            try:
                # Read the content, strip whitespace/newlines
                label_content = label_file.read_text().strip()
                
                # 3. Check if this label belongs to the main CPU package
                if label_content == "Package id 0":
                    
                    # 4. Determine the matching 'temp*_input' filename
                    # label_file.name looks like 'temp1_label', we replace '_label' with '_input'
                    input_filename = label_file.name.replace('_label', '_input')
                    input_file = hwmon_dir / input_filename
                    
                    if input_file.exists():
                        # Read the raw temperature value
                        raw_temp = input_file.read_text().strip()
                        
                        # Convert millidegrees Celsius to standard Celsius
                        celsius_temp = float(raw_temp) / 1000
                        
                        return f"{celsius_temp}°C"
                        return  # Exit early since we found 'Package id 0'
                        
            except (PermissionError, ValueError, FileNotFoundError):
                # Safely skip files that are locked, unreadable, or missing
                continue
    return


def cores():
    return "Temp " + print_cpu_package_temp()

def memory():
    meminfo = dict((i.split()[0].rstrip(':'), int(i.split()[1])) for i in open('/proc/meminfo').readlines())
    used = meminfo['MemTotal'] - meminfo['MemFree'] - meminfo['Cached']
    percentaje_used = (used*100)/meminfo['MemTotal']

    return 'Mem: %.1f GB (%d%%)' % (used/(1024*1024), math.ceil(percentaje_used))

def wireless():
    try:
        with open("/proc/net/wireless") as f:
            for line in f.readlines():
                if ":" in line:
                    lines = list(filter(None, line.split(" ")))
                    return math.ceil(float(lines[2] + "0")*100/70)
    except:
        return None
    return None

def latency_to_gateway():
    try:
        with open("/proc/net/route") as f:
            for line in f:
                fields = line.strip().split()
                if fields[1] != '00000000' or not int(fields[3], 16) & 2:
                    continue
                gateway = socket.inet_ntoa(struct.pack("<L", int(fields[2], 16)))
                myping = ping()
                return str(math.ceil(myping.get_ping_time(gateway).real * 1000))
    except:
        pass
    return None

# Define the path for the lock file
try:
    lock_file = open("/tmp/tint2_stats.lock", "w")
    fcntl.lockf(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
except IOError:
    print("Instance already running.")
    sys.exit(1)

linux_icon = '<span foreground="#dda50a">&#xf17c;</span>'
root = root_usage()
root_usage_str = '<span foreground="#ffaaaa">&#xf0a0; ' + root + '</span>'
total_cores = cores()
cores_str = '<span foreground="#aaffaa">&#xf2db; ' + total_cores + '</span>'
memory = memory()
memory_usage_str = '<span foreground="#ffffaa">&#xf538; ' + memory + '</span>'

#wireless = wireless()
#if not wireless:
#    wireless_signal_str = '<span foreground="#ffffdd">&#xf796; Wired</span>'
#else:
#    wireless_signal_str = '<span foreground="#ffffdd">&#xf1eb; ' + str(wireless) + '%</span>'
#
#latency = latency_to_gateway()
#if not latency:
#    latency_to_router_str = '<span foreground="#faa">&#xf0ac; (&#xf071;)</span> '
#else:
#    latency_to_router_str = '<span foreground="#7af">&#xf0ac; (' + latency + ' ms)</span> '

#print(root_usage_str + ' | ' + cores_str + ' | ' + memory_usage_str + ' | ' + wireless_signal_str + ' | ' + latency_to_router_str)
print(root_usage_str + ' | ' + cores_str + ' | ' + memory_usage_str) # + ' | ' + wireless_signal_str + ' | ' + latency_to_router_str)
