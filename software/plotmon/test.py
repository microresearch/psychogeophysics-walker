import Queue
import threading
import time, datetime
import serial

ser = serial.Serial('/dev/ttyUSB0', 57600, timeout=1)

while True:
    print ser.readline()
