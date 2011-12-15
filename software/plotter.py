import Tkinter, tkFileDialog

root = Tkinter.Tk()
root.withdraw()

file = tkFileDialog.askopenfile(parent=root,mode='rb',title='Choose a file')
if file != None:
    data = file.read()

#### plotting functions for this file

### first parsing after gps stuff from before and perhaps write to new
### file after... for example calculate magnitude from real and img:

### following:
### magn=sqrt(fft_real_data*fft_real_data+fft_img_data*fft_img_data);
###
### env: GPS, temp, light, lf, hf, FGM, RNG
### psyche: real, imag, temperature, gsr

## then plotting various versions according to name of file in logimages

## strip down from title.log to title + combinations of lf usw for
## what is plotted
