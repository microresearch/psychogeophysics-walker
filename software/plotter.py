import Tkinter, tkFileDialog
from pylab import *
import csv, os, Gnuplot, Gnuplot.funcutils, re

g = Gnuplot.Gnuplot(debug=1)
NMI = 1852.0
D2R = pi/180.0
root = Tkinter.Tk()
root.withdraw()

#file = tkFileDialog.askopenfile(parent=root,mode='rb',title='Choose a file')

nfile=open('testlogs/201112171837.log')
nnfile=str(nfile.name)
newfile=file(nnfile[:-4]+"mod.log",'w')

def calc_limit_high_005(range):
        var = (1.96 / 2) * math.sqrt(range)
        limit_high = range/2 + var
        return limit_high

def process_env(line,lastrng,cnt):
    """env: GPS01, temp2, light3, lf4, hf5, FGM6, RNG7 (8) + timestamp"""
    eline=line[3:]
    elist=eline.split(',')
    if int(elist[7])<100:
        rngcum=(50-int(elist[7]))+int(lastrng)
    else:
        rngcum=int(lastrng)
    distcum=(calc_limit_high_005(cnt*100))-(cnt*50)
    distcum2=(cnt*50)-(calc_limit_high_005(cnt*100))
    cnt+=1
    return[float(elist[0]),float(elist[1]),float(elist[2]),int(elist[3]),int(elist[4]),int(elist[5]),int(elist[6]),int(elist[7]), rngcum, distcum, distcum2], rngcum, cnt


def process_psyche(line, oldata, starter):
    """ psyche: real, imag, temperature, gsr (4) + timestamp"""
    pline=line[3:]
    plist=pline.split(',')
    magn=sqrt(int(plist[0])*int(plist[0])+int(plist[1])*int(plist[1]));

# how to average temp2, gsr3 and imp0+1
    oldtemp=float(plist[2])+oldata[0]
    oldgsr=int(plist[3])+oldata[1]
    oldimp=magn+oldata[2]

    avtemp=oldtemp/starter
    avgsr=oldgsr/starter
    avimp=oldimp/starter

    return [avtemp,avgsr,avimp], [oldtemp,oldgsr,oldimp]

starter=0
oldata=[0,0,0]
cnt=0
rng=0

for line in nfile:
    if re.search("e:",line):
        envdata,rng,cnt=process_env(line,rng,cnt)
        starter=0
        cnt+=1
        oldata=[0,0,0]
        envi=", ".join(map(str, envdata))
        pvi=", ".join(map(str, pdata))
        combi=envi+" , "+pvi+"\n"
        print combi
        newfile.write(combi)
        newfile.flush()

    if re.search("p:",line):
        starter+=1
        pdata,oldata=process_psyche(line,oldata, starter)

## then plotting various versions according to name of file in logimages

## strip down from title.log to title + combinations of lf usw for
## what is plotted

