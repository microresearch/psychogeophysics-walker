"""
Listen to serial, return most recent numeric values
Lots of help from here:
http://stackoverflow.com/questions/1093598/pyserial-how-to-read-last-line-sent-from-serial-device
"""

#TODO:

# access to 3 serial streams and decide which stream is which
# how to attach x streams to main software (each stream embeds more
# data which needs to be parsed out and saved

from threading import Thread
import time, datetime
import serial

last_received = ''
def receiving(ser):
    global last_received
    buffer = ''
    while True:
        buffer = buffer + ser.read(ser.inWaiting())
        if '\n' in buffer:
            lines = buffer.split('\n') # Guaranteed to have at least 2 entries
            last_received = lines[-2]
            #If the Arduino sends lots of empty lines, you'll lose the
            #last filled line, so you could make the above statement conditional
            #like so: if lines[-2]: last_received = lines[-2]
            buffer = lines[-1]


class SerialData(object):
    def __init__(self, init=50):

        now = datetime.datetime.now()
        numm=now.strftime("%Y%m%d%H%M")

        self.f = file("%s.results.log" %numm, 'w')
        try:
            # change for SERIAL PORT LOCATION
            self.ser = ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=1)
        except serial.serialutil.SerialException:
            #no serial connection
            self.ser = None
        else:
            Thread(target=receiving, args=(self.ser,)).start()
        
    def next(self):
        if not self.ser:
            return 100 #return anything so we can test when Arduino isn't connected
        #return a float value or try a few times until we get one
        for i in range(40):
            raw_line = last_received
            try:
                self.f.write("%s\n" %raw_line.strip())
                self.f.flush()
                return float(raw_line.strip())
            except ValueError:
                print 'bogus data',raw_line
                time.sleep(.005)
        return 0.
    def __del__(self):
        self.f.close()
        if self.ser:
            self.ser.close()

if __name__=='__main__':
    s = SerialData()
    for i in range(500):
        time.sleep(.015)
        print s.next()
