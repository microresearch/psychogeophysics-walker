"""
Some serial port utilities for Windows and PySerial

Eli Bendersky (eliben@gmail.com)
License: this code is in the public domain

Ported to Linux:

"""
import re, itertools, glob

def scan():
    """scan for available ports. return a list of device names."""
    return glob.glob('/dev/ttyUSB*')
   
def full_port_name(portname):
    return portname    
    

def enumerate_serial_ports():

    """ return an iterator of serial ports existing on this
        computer.
    """

    ports=[]

    for name in scan():
        ports.append(name)

    return ports



if __name__ == "__main__":
    import serial
    for p in enumerate_serial_ports():
#        print p, full_port_name(p)
        print p



