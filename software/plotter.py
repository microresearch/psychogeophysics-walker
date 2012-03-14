import Tkinter, tkFileDialog
from pylab import *
import csv, os, Gnuplot, Gnuplot.funcutils, re

g = Gnuplot.Gnuplot(debug=1)
NMI = 1852.0
D2R = pi/180.0
root = Tkinter.Tk()
root.withdraw()

nfile = tkFileDialog.askopenfile(parent=root,mode='rb',title='Choose a file')

#nfile=open('testlogs/201112201410_1.log')
nnfile=str(nfile.name)
newfile=file(nnfile[:-4]+"mod.log",'w')

def calc_limit_high_005(range):
        var = (1.96 / 2) * math.sqrt(range)
        limit_high = range/2 + var
        return limit_high

def process_env(elist,lastrng,cnt):
    """env: GPS01, temp2, light3, lf4, hf5, FGM6, RNG7 (8) + timestamp"""

    if int(elist[7])<100:
        rngcum=(50-int(elist[7]))+int(lastrng)
    else:
        rngcum=int(lastrng)
    distcum=(calc_limit_high_005(cnt*100))-(cnt*50)
    distcum2=(cnt*50)-(calc_limit_high_005(cnt*100))
    cnt+=1    
    return[float(elist[0]),float(elist[1]),float(elist[2]),int(elist[3]),int(elist[4]),int(elist[5]),int(elist[6]),int(elist[7]), rngcum, distcum, distcum2], rngcum, cnt


def process_psyche(plist, oldata, starter):
    """ psyche: real, imag, temperature, gsr (4) + timestamp"""
    magn=sqrt(int(plist[0])*int(plist[0])+int(plist[1])*int(plist[1]));

# how to average temp2, gsr3 and imp0+1
    oldtemp=float(plist[2])+oldata[1]
    oldgsr=int(plist[3])+oldata[2]
    oldimp=magn+oldata[0]

    avtemp=oldtemp/starter
    avgsr=oldgsr/starter
    avimp=oldimp/starter

    return [avimp,avtemp,avgsr], [oldimp,oldtemp,oldgsr]

def read_csv_file(filename):
    data = []
    for row in csv.reader(open(filename)):
        data.append(row)
    return data

def process_gps_data(data):
    """GPS01, temp2, light3, lf4, hf5, FGM6, RNG7, RNGCU, dist1,
    dist2, magn, temperature, gsr"""

    latitude    = []
    longitude   = []
    outtemp =[]
    light          = []
    lf = []
    hf=[]
    FGM=[]
    RNG=[]
    RNGCUM=[]
    distcum1=[]
    distcum2=[]
    magn=[]
    bodytemp=[]
    gsr=[]

    for row in data:
        latitude.append(float(row[0][0:2]) + \
                            float(row[0][2:])/60.0)
        longitude.append((float(row[1][0:3]) + \
                              float(row[1][3:])/60.0))
#        print(float(row[1][0:3]) + float(row[1][3:])/60.0)
        outtemp.append(float(row[2]))
        light.append(float(row[3]))
        lf.append(float(row[4]))
        hf.append(float(row[5]))
        FGM.append(float(row[6]))
        RNG.append(float(row[7]))
        RNGCUM.append(float(row[8]))
        distcum1.append(float(row[9]))
        distcum2.append(float(row[10]))
        magn.append(float(row[11]))
        bodytemp.append(float(row[12]))
        gsr.append(float(row[13]))

    return (array(latitude), array(longitude), \
                array(outtemp), array(light), array(lf), array(hf),array(FGM),array(RNG), \
                array(RNGCUM),array(distcum1),array(distcum2),array(magn),array(bodytemp),\
                array(gsr))


starter=0
oldata=[0,0,0]
cnt=0
rng=0

for line in nfile:
    if re.search("e:",line):
        eline=line[3:]
        elist=eline.split(',')

        if len(elist)==9 and len(elist[0])>0 and len(elist[1])>0 and len(elist[2])>0 and len(elist[3])>0 and len(elist[4])>0 and len(elist[5])>0 and len(elist[6])>0 and len(elist[7])>0:
            envdata,rng,cnt=process_env(elist,rng,cnt)
            starter=0
            cnt+=1
            oldata=[0,0,0]
            envi=", ".join(map(str, envdata))
            pvi=", ".join(map(str, pdata))
            combi=envi+" , "+pvi+"\n"
#            print combi
            newfile.write(combi)
            newfile.flush()

    if re.search("p:",line):
        pline=line[3:]
        plist=pline.split(',')
        starter+=1
        if len(plist)>3 and len(plist[0])>0 and len(plist[1])>0 and len(plist[2])>0 :
            pdata,oldata=process_psyche(plist,oldata, starter)

## then plotting various versions according to name of file in logimages
## strip down from title.log to title + combinations of lf usw for
## what is plotted

y=read_csv_file(newfile.name)

#    return (array(latitude), array(longitude), \
#                array(outtemp), array(light), array(lf), array(hf),array(FGM),array(RNG), \
#                array(RNGCUM),array(distcum1),array(distcum2),array(magn),array(bodytemp),\
#                array(gsr))


(lat, long, outtemp, light,lf,hf,FGM,RNG,RNGCUM,distcum1,distcum2,magn,bodytemp,gsr) = process_gps_data(y)

newy=[]
py = (lat-min(lat))*NMI*60.0
print min(lat)
print max(lat)
px = (long-min(long))*NMI*60.0*cos(D2R*lat)

for a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14 in zip(py,px, outtemp, light,lf,hf,FGM,RNG,RNGCUM,distcum1,distcum2,magn,bodytemp,gsr):
    newy.append((a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14))

basetitle=nnfile[-16:-4]
baseout="logimages/"

g('set parametric')
g('set style data line')
g('set surface')
g('unset key')
g('unset contour')
g('set dgrid3d 80,80,30')
g('set xlabel "metres WE"') 
g('set ylabel "metres NS"') 
g('set view 60,20')
#g('set term png size 14043,9933') # A0
#g('set term png size 1024,768') # example
g('set term png size 2500,1875') # A0

# TEMP:

out=baseout+basetitle+"temp.png"
title=basetitle+" temperature ext and body "

g.title(title)
g('set output \"'+ out + '\"')

g.splot(Gnuplot.Data(newy, using=(1,2,3), with='lines'),Gnuplot.Data(newy, using=(1,2,13), with='lines')) 

# RNG:

out=baseout+basetitle+"rng.png"
title=basetitle+" cumulative RNG and 0.05"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,9), with='lines'),Gnuplot.Data(newy, using=(1,2,10), with='lines'),Gnuplot.Data(newy, using=(1,2,11), with='lines'))

# light (4)

out=baseout+basetitle+"light.png"
title=basetitle+" light intensity"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,4), with='lines'))

# lf and hf (5,6)

out=baseout+basetitle+"freq.png"
title=basetitle+" low and high frequency intensity"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,5), with='lines'),Gnuplot.Data(newy, using=(1,2,6), with='lines'))

# fgm 7

out=baseout+basetitle+"mag.png"
title=basetitle+" magnetic field strength"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,7), with='lines'))

# magn 12

out=baseout+basetitle+"imp.png"
title=basetitle+" impedance"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,12), with='lines'))

# gsr 14

out=baseout+basetitle+"gsr.png"
title=basetitle+" GSR"
g.title(title)
g('set output \"'+ out + '\"')
g.splot(Gnuplot.Data(newy, using=(1,2,14), with='lines'))




