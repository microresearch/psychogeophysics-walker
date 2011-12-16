import Tkinter, tkFileDialog
from pylab import *
import csv, os, Gnuplot, Gnuplot.funcutils

g = Gnuplot.Gnuplot(debug=1)
NMI = 1852.0
D2R = pi/180.0
root = Tkinter.Tk()
root.withdraw()

file = tkFileDialog.askopenfile(parent=root,mode='rb',title='Choose a file')
if file != None:
    data = file.read()

#### plotting functions for this file

### first parsing after gpsgsr.py and perhaps write to new file
### for example calculate magnitude from real and img, and
### cumulative RNG

### following:
### magn=sqrt(fft_real_data*fft_real_data+fft_img_data*fft_img_data);
###
### env: GPS, temp, light, lf, hf, FGM, RNG
### psyche: real, imag, temperature, gsr

### how to deal with eeg data in between - format????

## then plotting various versions according to name of file in logimages

## strip down from title.log to title + combinations of lf usw for
## what is plotted
