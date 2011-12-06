""" 
first test code for walker project:

-*** first test stage:

- check and assign all 3 serial streams correctly
- write these to a log file as they come in to check sync
- timestamping
- parse each value from the 3 streams -> 10 or 11 data sources (or how many we have in testcase)
- check for errors (eg. same values consistently in data source, GPS problems) and alert usre to error

-*** second stage

- threading - is parsing in thread or...?
- design user interface // wx or curses

"""
import Queue
import threading
import time, datetime
import serial,glob,re
import os
import pprint
import random
import sys

class EEGThread(threading.Thread):
    """ 
    """
    def __init__(   self, 
                    data_q, error_q, 
                    whichport,
                    ):
        threading.Thread.__init__(self)

        self.port=whichport
        self.data_q = data_q
        self.error_q = error_q
        
        self.alive = threading.Event()
        self.alive.set()
        
    def run(self):
        state=1

        while True:
            # later deal with queues
         if state == 1:
             # find sync0 (0xa5)
             x = ord(ser.read())
             if x == 0xa5:
                 state = 2
         elif state == 2:
                 # find sync1 (0x5a)
             x = ord(self.port.read())
             if x == 0x5a:
                 state = 3
         elif state == 3:
             version = ord(self.port.read())
             count = ord(self.port.read())
             s = self.port.read(12)
             data = [ord(s[i])*256+ord(s[i+1]) for i in range(0,len(s),2)]
             switches = ord(self.port.read())
             print data[0], # channel 1
             state = 1

        if self.port:
            self.port.close()

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

# unique file for logging to

now = datetime.datetime.now()
numm=now.strftime("%Y%m%d%H%M")
filly = file("%s.results.log" %numm, 'w')

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

    if re.search("e:",line):
        envboard=ser
        print "envboard detected at: %s" %(port)

    if re.search("\$GP",line):
        gpsboard=ser
        print "GPS detected at: %s" %(port)

    if re.search(chr(0xa5),line):
        eeg=ser
        print "EEG detected at: %s" %(port)

# start up threads to read each stream.

queue=[]
error=[]

EEGThread(queue, error, eeg).start()

# sync to write with timestamp to file



# while True:
#     line=envboard.readline(); 
#     if len(line)>5:
#         line=line[5:]
#         value=int(line)
#         print value
