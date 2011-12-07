""" 
first test code for walker project.

notes: wait a while for envboard

"""

import Queue
import threading
import time, datetime
import serial,glob,re
import os
import pprint
import random
import sys

def timestamp():
    now = time.time()
    localtime = time.localtime(now)
    milliseconds = '%03d' % int((now - int(now)) * 1000)
    return time.strftime('%Y%m%d%H%M%S', localtime) + milliseconds

def get_all_from_queue(Q):
    """ Generator to yield one after the others all items 
        currently in the queue Q, without any waiting.
    """
    try:
        while True:
            yield Q.get_nowait( )
    except Queue.Empty:
        raise StopIteration


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
         if state == 1:
             # find sync0 (0xa5)
             x = ord(self.port.read())
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
#             print data[0], # channel 1
             self.data_q.put(data[0])
             self.data_q.put(",")
             state = 1

        if self.port:
            self.port.close()

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

class ENVThread(threading.Thread):
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
        while True:
            # when we get a line of data. read it and signal main xxxxx
            # to write ENV and EEG queues(?) to the file
            if self.port.inWaiting():
                data = self.port.readline()
            
                if len(data) > 2:
                    now = datetime.datetime.now()
                    sttamp = timestamp() 
#                    self.data_q.put("\n")
                    self.data_q.put(sttamp)
                    self.data_q.put(",")
                    self.data_q.put(data[3:-2])
                    self.data_q.put(",")


        if self.port:
            self.port.close()

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)


# unique file for logging to

now = datetime.datetime.now()
tstamp=now.strftime("%Y%m%d%H%M")
filly = file("%s.results.log" %tstamp, 'w')

# list serial ports
def scan():
    """scan for available ports. return a list of device names."""
    return glob.glob('/dev/ttyUSB*')

ports=scan()
print "Ports found: %s" %(ports)
env=0
eeg=0

for port in ports:
    ser = serial.Serial(port, 57600, timeout=1) # we need a whole line 
    line = ser.read(128)

#    print line

    if re.search("e:",line):
        env=ser
        print "envboard detected at: %s" %(port) # at present env only prints when has fix!

    if re.search(chr(0xa5),line):
        eeg=ser
        print "EEG detected at: %s" %(port)

data_q = Queue.Queue()
error_q = Queue.Queue()

if eeg:
    EEGThread(data_q, error_q, eeg).start()
if env:
    ENVThread(data_q, error_q, env).start()
else:
    print "Nothing to do! Nothing attached"
    exit()

# write header: date, attached ports

filly.write("%s " %(tstamp)),
if env:
    filly.write("env, "),
if eeg:
    filly.write("EEG\n")

while True: 
    qdata = list(get_all_from_queue(data_q))
    if len(qdata) > 0:
#        print "".join(map(str, qdata)),
        os.system("clear")
        print "writing: eeg %d env: %d" %(0 if eeg==0 else 1, 0 if env==0 else 1)

# data sanity?

        filly.write("".join(map(str,qdata)))
        filly.flush()
        

