from pylab import *
import csv, os, Gnuplot, Gnuplot.funcutils, re
from matplotlib.mlab import find
import numpy as np
import math

# what we want to end up with is:
#lat, lon, frequency /n


nfile=open('testlogs/testeeglog') # eeg logfile
nnfile=str(nfile.name)

def read_csv_file(filename):
    data = []
    for row in csv.reader(open(filename)):
        data.append(row)
    return data

# for test read first x (followed by lat, lon)

RATE=256 #openeeg sample rate

data=read_csv_file(nnfile)

# data[0]=eeg 
# data[1]=co-ords...

# how to step through?

# start with processing data[0]

# use a Blackman window

chunk=64

window = np.blackman(chunk)

# play stream and find the frequency of each chunk

d=[]

for x in data[128][:64]:
    d.append(float(x))


d1=np.array(d)

indata = d1
print indata
    # Take the fft and square each value
fftData=abs(np.fft.rfft(indata))**2

print fftData

    # find the maximum
which = fftData[1:].argmax() + 1
    # use quadratic interpolation around the max
if which != len(fftData)-1:
    y0,y1,y2 = np.log(fftData[which-1:which+2:])
    x1 = (y2 - y0) * .5 / (2 * y1 - y2 - y0)
        # find the frequency and output it
    thefreq = (which+x1)*RATE/chunk
    print "The freq is %f Hz." % (thefreq)
else:
    thefreq = which*RATE/chunk
    print "...The freq is %f Hz." % (thefreq)
    # read some more data





