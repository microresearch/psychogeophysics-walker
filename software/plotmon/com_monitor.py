import Queue
import threading
import time, datetime
import serial


class ComMonitorThread(threading.Thread):
    """ A thread for monitoring a COM port. The COM port is 
        opened when the thread is started.
    
        data_q:
            Queue for received data. Items in the queue are
            (data, timestamp) pairs, where data is a binary 
            string representing the received data, and timestamp
            is the time elapsed from the thread's start (in 
            seconds).
        
        error_q:
            Queue for error messages. In particular, if the 
            serial port fails to open for some reason, an error
            is placed into this queue.
        
        port:
            The COM port to open. Must be recognized by the 
            system.
        
        port_baud/stopbits/parity: 
            Serial communication parameters
        
        port_timeout:
            The timeout used for reading the COM port. If this
            value is low, the thread will return data in finer
            grained chunks, with more accurate timestamps, but
            it will also consume more CPU.
    """
    def __init__(   self, 
                    data_q, error_q, 
                    port_num,
                    port_baud,
                    port_stopbits=serial.STOPBITS_ONE,
                    port_parity=serial.PARITY_NONE,
                    port_timeout=1): # was 0.01
        threading.Thread.__init__(self)

        now = datetime.datetime.now()
        numm=now.strftime("%Y%m%d%H%M")
        self.f = file("%s.results.log" %numm, 'w')
        
        self.serial_port = None
        self.serial_arg = dict( port=port_num,
                                baudrate=port_baud,
                                stopbits=port_stopbits,
                                parity=port_parity,
                                timeout=port_timeout)

        self.data_q = data_q
        self.error_q = error_q
        
        self.alive = threading.Event()
        self.alive.set()
        
    def run(self):
        try:
            if self.serial_port: 
                self.serial_port.close()
            self.serial_port = serial.Serial(**self.serial_arg)
        except serial.SerialException, e:
            self.error_q.put(e.message)
            return
        
        # Restart the clock
        time.clock()
        
        while self.alive.isSet():
            # Reading 1 byte, followed by whatever is left in the
            # read buffer, as suggested by the developer of 
            # PySerial. // and if we want to read more...
            # 
            data = self.serial_port.readline()
#            data += self.serial_port.read(self.serial_port.inWaiting())
            
            if len(data) > 2:
                timestamp = time.clock()
                self.f.write("%s,%s\n" %(data.strip(), timestamp))
                self.f.flush()
                self.data_q.put((data, timestamp))
            
        # clean up
        if self.serial_port:
            self.serial_port.close()
            self.f.close()

    def join(self, timeout=None):
        self.alive.clear()
        threading.Thread.join(self, timeout)

