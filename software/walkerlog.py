""" 
first test code for walker project.

- headers for each:

env: GPS, temp, light, lf, hf, FGM, RNG

psyche: real, imag, temperature, gsr

TODO:

- test clean EEG logging!

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
        count=0
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
             # add to buffer and send over
#             buffer = buffer + str(data[0]) +","

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
                    toput="\n"+data[:-2]+","+sttamp+"\n"
                    
                    self.data_q.put(toput)

        if self.port:
            self.port.close()

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

class PSYCHEThread(threading.Thread):
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
                    toput="\n"+data[:-2]+","+sttamp+"\n"
                    self.data_q.put(toput)


        if self.port:
            self.port.close()

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)


# unique file for logging to

now = datetime.datetime.now()
tstamp=now.strftime("%Y%m%d%H%M")
filly = file("testlogs/%s.log" %tstamp, 'w')

# list serial ports
def scan():
    """scan for available ports. return a list of device names."""
    return glob.glob('/dev/ttyUSB*')

def attachment():
    """scan and attach"""
    global env
    global eeg
    global psyche
    ports=scan()
    print "TESTING: Ports found: %s" %(ports)
    count=0

    for port in ports:
        ser = serial.Serial(port, 57600, timeout=1) # we need a whole line 
        line = ser.read(128)

        if re.search("e:",line):
            env=ser
            print "environ detected at: %s" %(port) # at present env only prints when has fix!
            count=count+1

        if re.search(chr(0xa5),line):
            eeg=ser
            print "EEG detected at: %s" %(port)
            count=count+1

        if re.search("p:",line):
            psyche=ser
            print "psyche detected at: %s" %(port) # at present env only prints when has fix!
            count=count+1
    return count

eegdata=[]
env=0
psyche=0
eeg=0
expected = sys.argv[1]
res=attachment()

while (res<int(expected)):
    res=attachment()

# # while we just have: e: SATCNT: 12 // parse and print satcnt here and wait

# parsed=1
# while (parsed==1):
#     if env.inWaiting():
#         line = env.readline()
#         if re.search("e: SATCNT",line):
#             print ("SATCNT: %s" %line[11:])
#             parsed=1
#         elif re.search(",",line):
#             parsed=0


data_q = Queue.Queue()
eeg_q = Queue.Queue()
error_q = Queue.Queue()

if eeg:
    EEGThread(eeg_q, error_q, eeg).start()
    eegfilly=file("testlogs/%s.eeg.log" %tstamp, 'w')
    print("writing testlogs/%s.eeg.log" %tstamp)
if env:
    ENVThread(data_q, error_q, env).start()
if psyche:
    PSYCHEThread(data_q, error_q, psyche).start()

# write header: date, attached ports

filly.write("psychogeophysics walkerlog: %s " %(tstamp)),
if env:
    filly.write("env, "),
if psyche:
    filly.write("psyche, "),
#if eeg:
#    filly.write("EEG\n")

environ=''
psychee=''

x=0 # TESTING

while True: 
    signal=-1
    qdata = list(get_all_from_queue(data_q))
    if len(qdata) > 0:
#        print "".join(map(str, qdata)),
        os.system("clear")
        print "writing: eeg %d psyche: %d env: %d to %s.log\n" %(0 if eeg==0 else 1, 0 if psyche==0 else 1, 0 if env==0 else 1, tstamp)
        print("LON, LAT, temp, light, lf, hf, FGM, RNG")
        print ("%s" %(environ))
        print("real, imag, temperature, gsr")
        print ("%s" %(psychee))

#        if qdata starts with p: then strip gps and signal else no signal

# sometimes gpscoords are of psyche cut??? - queues together???

        if re.search("e:",str(qdata)):
            environ="".join(map(str,qdata))
            gpscoords=environ[4:24]
            signal=1
        if re.search("p:",str(qdata)):
            psychee="".join(map(str,qdata))

#    gpscoords="5205.5416,00714.0201"

#     if x>=256:
#         signal=1
#         x=0

    if eeg:    
        eegdata=list(get_all_from_queue(eeg_q))
        if len(eegdata) > 0:
            eegfilly.write("".join(map(str,eegdata)))
            eegfilly.flush()
            x=x+len(eegdata)

        if signal==1:
            eegfilly.write("\n")
            eegfilly.write("".join(gpscoords))
            eegfilly.write("\n")
            eegfilly.flush()

# write this the other way round ... maybe

    filly.write("".join(map(str,qdata)))
    filly.flush()

        
        

