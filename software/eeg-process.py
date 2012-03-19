from pylab import *
import csv, os, Gnuplot, Gnuplot.funcutils, re
from matplotlib.mlab import find
import numpy as np
import math

g = Gnuplot.Gnuplot(debug=1)
NMI = 1852.0
D2R = pi/180.0

def read_csv_file(filename):
    data = []
    for row in csv.reader(open(filename)):
        data.append(row)
    return data

def process_gps_data(data):
    latitude    = []
    longitude   = []
    intensity   = []

    for row in data:
        latitude.append(float(row[0][0:2]) + \
                            float(row[0][2:])/60.0)
        longitude.append((float(row[1][0:3]) + \
                              float(row[1][3:])/60.0))
        if len(row)>2:
            intensity.append(float(row[2]))
        else:
            intensity.append(0)

    return (array(latitude), array(longitude), \
                array(intensity))

def read_csv_file(filename):
    data = []
    for row in csv.reader(open(filename)):
        data.append(row)
    return data


nfile=open('testlogs/201203161747.eeg.log') # eeg logfile
nnfile=str(nfile.name)
newfile=file(nnfile[:-4]+"mod.log",'w')
RATE=256 #openeeg sample rate
data=read_csv_file(nnfile)
xx=0

for x,y in zip(data,data[1:]):
    zz=len(x)
    xx=xx+1
    if zz==2:
        gpscoords=", ".join(x)
        newfile.write(gpscoords)
        newfile.flush()

    if zz>2 and xx>1:
        d=[]
        for z in x[:zz-1]:
            d.append(float(z))

        d1=np.array(d)
        chunk = zz-1
        indata = d1
        fftData=abs(np.fft.rfft(indata))**2
        which = fftData[1:].argmax() + 1
        if which != len(fftData)-1:
            y0,y1,y2 = np.log(fftData[which-1:which+2:])
            x1 = (y2 - y0) * .5 / (2 * y1 - y2 - y0)
            thefreq = (which+x1)*RATE/chunk
        else:
            thefreq = which*RATE/chunk

        eegfreq=", "+str(thefreq)+"\n"
        newfile.write(eegfreq)
        newfile.flush()

# let's PLOT!        

y=read_csv_file(newfile.name)
(lat, long, intensity) = process_gps_data(y)
# translate spherical coordinates to Cartesian
py = (lat-min(lat))*NMI*60.0
px = (long-min(long))*NMI*60.0*cos(D2R*lat)
newy=[]
for x,yz,z in zip(px,py,intensity):
    newy.append((x,yz,z))

#print newy

basetitle=nnfile[-20:-4]
baseout="logimages/"

#gnuplot commands
g('set parametric')
g('set style data line')
g('set surface')
g('set key')
g('unset contour')
g('set dgrid3d 40,40,10')
g('set xlabel "metres EW"') 
g('set ylabel "metres SN"') 
g('set label "signal intensity"at -60,0,0') 
g('set view 60,20')
#g.title("wasserturm 13 March 2011")
g('set term png size 1024,768')
#g('set term png size 14043,9933') # A0
#g('set output "/root/projects/detection/logimages/scryturmcut.png"')

out=baseout+basetitle+".png"
title=basetitle+"Peak EEG frequencies"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,3), with='lines', title='frequency'))




