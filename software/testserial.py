""" 
first test code for walker project:

TODO in order:

-*** need to break down, also with use of threading:

- serial and parsing thread feeds data to
  
  UI/graphing

-*** first test stage:

- check and assign all 3 serial streams correctly
- write these to a log file as they come in to check sync
- timestamping
- parse each value from the 3 streams -> 10 or 11 data sources (or how many we have in testcase)
- check for errors (eg. same values consistently in data source, GPS problems) and alert usre to error

-*** second stage

- threading - is parsing in thread or...?
- design wx user interface // or curses
- integrate with matplotlib // seperate plotting app.
- EEG decoding and analysis
- walk-flow of initialise, is all going, keep user updates

-**update

_ 3 threads - handle and parse data - sync - signalling?
_ parsing gps on env board 


"""

from threading import Thread
import time, datetime
import serial,glob,re
import os
import pprint
import random
import sys
import wx

# list serial ports
def scan():
    """scan for available ports. return a list of device names."""
    return glob.glob('/dev/ttyUSB*')

ports=scan()
print ports
#if len(ports)<3: 
#    print "Error: we have less than 3 devices"
#    raise Exception

# run through ports and identify

for port in ports:
    ser = serial.Serial(port, 57600, timeout=1) # we need a whole line 
    line = ser.read(128)
#    print line
# parse line - is env board (e: , eeg ?format? or p:) 
# these are determiners for serial stream

    if re.search("test",line):
        envboard=ser
        print "envboard detected at: %s" %(port)

    if re.search("\$GP",line):
        gpsboard=ser
        print "GPS detected at: %s" %(port)


while True:
    line=envboard.readline(); 
    if len(line)>5:
        line=line[5:]
        value=int(line)
        print value
