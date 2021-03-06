#!/bin/sh
# This is a shell archive (produced by GNU sharutils 4.9).
# To extract the files from this archive, save it to some FILE, remove
# everything before the `#!/bin/sh' line above, then type `sh FILE'.
#
lock_dir=_sh25016
# Made on 2010-12-12 18:37 CET by <email@anonym;.
# Source directory was `/tmp/rrr'.
#
# Existing files will *not* be overwritten, unless `-c' is specified.
#
# This shar contains:
# length mode name
# ------ ---------- ------------------------------------------
# 251 -rw-r--r-- ad7766.dcm
# 943 -rw-r--r-- ad7766.lib
# 249 -rw-r--r-- ad7766_x.dcm
# 943 -rw-r--r-- ad7766_x.lib
# 1928 -rw-r--r-- TSSOP16.mod
#
MD5SUM=${MD5SUM-md5sum}
f=`${MD5SUM} --version | egrep '^md5sum .*(core|text)utils'`
test -n "${f}" && md5check=true || md5checkalse
${md5check} || \
echo 'Note: not verifying md5sums. Consider installing GNU coreutils.'
save_IFS="${IFS}"
IFS="${IFS}:"
gettext_dirAILED
locale_dirAILED
first_param="$1"
for dir in $PATH
do
if test "$gettext_dir" = FAILED && test -f $dir/gettext \
&& ($dir/gettext --version >/dev/null 2>&1)
then
case `$dir/gettext --version 2>&1 | sed 1q` in
*GNU*) gettext_dir=$dir ;;
esac
fi
if test "$locale_dir" = FAILED && test -f $dir/shar \
&& ($dir/shar --print-text-domain-dir >/dev/null 2>&1)
then
locale_dir=`$dir/shar --print-text-domain-dir`
fi
done
IFS="$save_IFS"
if test "$locale_dir" = FAILED || test "$gettext_dir" = FAILED
then
echocho
else
TEXTDOMAINDIR=$locale_dir
export TEXTDOMAINDIR
TEXTDOMAIN=sharutils
export TEXTDOMAIN
echo="$gettext_dir/gettext -s"
fi
if (echo "testing\c"; echo 1,2,3) | grep c >/dev/null
then if (echo -n test; echo 1,2,3) | grep n >/dev/null
then shar_n= shar_c='
'
else shar_n=-n shar_c= ; fi
else shar_n= shar_c='\c' ; fi
f=shar-touch.$$
st100112312359.59
st223123592001.59
st2tr23123592001.5 # old SysV 14-char limit
st3231235901

if touch -am -t ${st1} ${f} >/dev/null 2>&1 && \
test ! -f ${st1} && test -f ${f}; then
shar_touch='touch -am -t $1$2$3$4$5$6.$7 "$8"'

elif touch -am ${st2} ${f} >/dev/null 2>&1 && \
test ! -f ${st2} && test ! -f ${st2tr} && test -f ${f}; then
shar_touch='touch -am $3$4$5$6$1$2.$7 "$8"'

elif touch -am ${st3} ${f} >/dev/null 2>&1 && \
test ! -f ${st3} && test -f ${f}; then
shar_touch='touch -am $3$4$5$6$2 "$8"'

else
shar_touch=:
echo
${echo} 'WARNING: not restoring timestamps. Consider getting and
installing GNU `touch'\'', distributed in GNU coreutils...'
echo
fi
rm -f ${st1} ${st2} ${st2tr} ${st3} ${f}
#
if test ! -d ${lock_dir} ; then :
else ${echo} "lock directory ${lock_dir} exists"
exit 1
fi
if mkdir ${lock_dir}
then ${echo} "x - created lock directory ${lock_dir}."
else ${echo} "x - failed to create lock directory ${lock_dir}."
exit 1
fi
# ============= ad7766.dcm ==============
if test -f 'ad7766.dcm' && test "$first_param" != -c; then
${echo} "x - SKIPPING ad7766.dcm (file already exists)"
else
${echo} "x - extracting ad7766.dcm (text)"
sed 's/^X//' << 'SHAR_EOF' > 'ad7766.dcm' &&
EESchema-DOCLIB Version 2.0 Date: nie, 12 gru 2010, 15:35:20
#
$CMP AD7766
D AD7766: 24-Bit, 8.5 mW, 109 dB, 128 kSPS ADC
F http://www.analog.com/en/analog-to-digital-converters/ad-converters/ad7766/products/product.html
$ENDCMP
#
#End Doc Library
SHAR_EOF
(set 20 10 12 12 15 35 20 'ad7766.dcm'
eval "${shar_touch}") && \
chmod 0644 'ad7766.dcm'
if test $? -ne 0
then ${echo} "restore of ad7766.dcm failed"
fi
if ${md5check}
then (
${MD5SUM} -c >/dev/null 2>&1 || ${echo} 'ad7766.dcm': 'MD5 check failed'
) << \SHAR_EOF
389f460afb995475444287b3ce5f3ddf ad7766.dcm
SHAR_EOF
else
test `LC_ALL wc -c < 'ad7766.dcm'` -ne 251 && \
${echo} "restoration warning: size of 'ad7766.dcm' is not 251"
fi
fi
# ============= ad7766.lib ==============
if test -f 'ad7766.lib' && test "$first_param" != -c; then
${echo} "x - SKIPPING ad7766.lib (file already exists)"
else
${echo} "x - extracting ad7766.lib (text)"
sed 's/^X//' << 'SHAR_EOF' > 'ad7766.lib' &&
EESchema-LIBRARY Version 2.3 Date: nie, 12 gru 2010, 15:35:20
#
# AD7766
#
DEF AD7766 U 0 40 Y Y 1 F N
F0 "U" 300 700 60 H V C CNN
F1 "AD7766" -100 700 60 H V C CNN
F2 "TSSOP16" -1200 800 60 H V C CNN
F3 "http://www.analog.com/static/imported-files/data_sheets/AD7766.pdf" 250 900 60 H V C CNN
DRAW
S -400 600 450 -300 0 1 0 N
XX AVDD 1 -700 500 300 R 50 50 1 1 W
XX VREF+ 2 -700 400 300 R 50 50 1 1 W
XX REFGND 3 -700 300 300 R 50 50 1 1 W
XX VIN+ 4 -700 200 300 R 50 50 1 1 I
XX VIN- 5 -700 100 300 R 50 50 1 1 I
XX AGND 6 -700 0 300 R 50 50 1 1 I
XX ~SYNC~/~PD~ 7 -700 -100 300 R 50 50 1 1 I
XX DVDD 8 -700 -200 300 R 50 50 1 1 I
XX VDRIVE 9 750 -200 300 L 50 50 1 1 W
XX SDO 10 750 -100 300 L 50 50 1 1 O
XX DGND 11 750 0 300 L 50 50 1 1 W
XX DRDY 12 750 100 300 L 50 50 1 1 O
XX SCLK 13 750 200 300 L 50 50 1 1 I
XX MCLK 14 750 300 300 L 50 50 1 1 I
XX SDI 15 750 400 300 L 50 50 1 1 I
XX ~CS~ 16 750 500 300 L 50 50 1 1 I
ENDDRAW
ENDDEF
#
#End Library
SHAR_EOF
(set 20 10 12 12 15 35 20 'ad7766.lib'
eval "${shar_touch}") && \
chmod 0644 'ad7766.lib'
if test $? -ne 0
then ${echo} "restore of ad7766.lib failed"
fi
if ${md5check}
then (
${MD5SUM} -c >/dev/null 2>&1 || ${echo} 'ad7766.lib': 'MD5 check failed'
) << \SHAR_EOF
5a21ad548daa002edb2d8786f056a0c7 ad7766.lib
SHAR_EOF
else
test `LC_ALL wc -c < 'ad7766.lib'` -ne 943 && \
${echo} "restoration warning: size of 'ad7766.lib' is not 943"
fi
fi
# ============= ad7766_x.dcm ==============
if test -f 'ad7766_x.dcm' && test "$first_param" != -c; then
${echo} "x - SKIPPING ad7766_x.dcm (file already exists)"
else
${echo} "x - extracting ad7766_x.dcm (text)"
sed 's/^X//' << 'SHAR_EOF' > 'ad7766_x.dcm' &&
EESchema-DOCLIB Version 2.0 Date: nie, 12 gru 2010, 15:42:38
#
$CMP AD7766
D AD7766 24-Bit, 8.5 mW, 109 dB, 128 kSPS ADC
F http://www.analog.com/en/analog-to-digital-converters/ad-converters/ad7766/products/product.html
$ENDCMP
#
#End Doc Library
SHAR_EOF
(set 20 10 12 12 15 42 38 'ad7766_x.dcm'
eval "${shar_touch}") && \
chmod 0644 'ad7766_x.dcm'
if test $? -ne 0
then ${echo} "restore of ad7766_x.dcm failed"
fi
if ${md5check}
then (
${MD5SUM} -c >/dev/null 2>&1 || ${echo} 'ad7766_x.dcm': 'MD5 check failed'
) << \SHAR_EOF
002f8d8bb34299ba3b43f5d453d24d3e ad7766_x.dcm
SHAR_EOF
else
test `LC_ALL wc -c < 'ad7766_x.dcm'` -ne 249 && \
${echo} "restoration warning: size of 'ad7766_x.dcm' is not 249"
fi
fi
# ============= ad7766_x.lib ==============
if test -f 'ad7766_x.lib' && test "$first_param" != -c; then
${echo} "x - SKIPPING ad7766_x.lib (file already exists)"
else
${echo} "x - extracting ad7766_x.lib (text)"
sed 's/^X//' << 'SHAR_EOF' > 'ad7766_x.lib' &&
EESchema-LIBRARY Version 2.3 Date: nie, 12 gru 2010, 15:42:38
#
# AD7766
#
DEF AD7766 U 0 40 Y Y 1 F N
F0 "U" 200 1150 60 H V C CNN
F1 "AD7766" 150 200 60 H V C CNN
F2 "TSSOP16" -1250 1400 60 H I C CNN
F3 "http://www.analog.com/static/imported-files/data_sheets/AD7766.pdf" 200 1500 60 H I C CNN
DRAW
S -750 1050 400 300 0 1 0 N
XX AVDD 1 -300 1350 300 D 50 50 1 1 W
XX VREF+ 2 -400 1350 300 D 50 50 1 1 W
XX REFGND 3 -400 0 300 U 50 50 1 1 W
XX VIN+ 4 -1050 700 300 R 50 50 1 1 I
XX VIN- 5 -1050 600 300 R 50 50 1 1 I
XX AGND 6 -300 0 300 U 50 50 1 1 I
XX ~SYNC~/~PD~ 7 700 350 300 L 50 50 1 1 I
XX DVDD 8 -100 1350 300 D 50 50 1 1 I
XX VDRIVE 9 0 1350 300 D 50 50 1 1 W
XX SDO 10 700 450 300 L 50 50 1 1 O
XX DGND 11 -100 0 300 U 50 50 1 1 W
XX DRDY 12 700 550 300 L 50 50 1 1 O
XX SCLK 13 700 650 300 L 50 50 1 1 I
XX MCLK 14 700 750 300 L 50 50 1 1 I
XX SDI 15 700 850 300 L 50 50 1 1 I
XX ~CS~ 16 700 950 300 L 50 50 1 1 I
ENDDRAW
ENDDEF
#
#End Library
SHAR_EOF
(set 20 10 12 12 15 42 38 'ad7766_x.lib'
eval "${shar_touch}") && \
chmod 0644 'ad7766_x.lib'
if test $? -ne 0
then ${echo} "restore of ad7766_x.lib failed"
fi
if ${md5check}
then (
${MD5SUM} -c >/dev/null 2>&1 || ${echo} 'ad7766_x.lib': 'MD5 check failed'
) << \SHAR_EOF
bbc045aa019084d194e459cbd21845c1 ad7766_x.lib
SHAR_EOF
else
test `LC_ALL wc -c < 'ad7766_x.lib'` -ne 943 && \
${echo} "restoration warning: size of 'ad7766_x.lib' is not 943"
fi
fi
# ============= TSSOP16.mod ==============
if test -f 'TSSOP16.mod' && test "$first_param" != -c; then
${echo} "x - SKIPPING TSSOP16.mod (file already exists)"
else
${echo} "x - extracting TSSOP16.mod (text)"
sed 's/^X//' << 'SHAR_EOF' > 'TSSOP16.mod' &&
PCBNEW-LibModule-V1 nie, 12 gru 2010, 15:39:43
$INDEX
TSSOP16
$EndINDEX
$MODULE TSSOP16
Po 0 0 0 15 4D04DE0D 4D04DDE3 ~~
Li TSSOP16
Cd TSOP16pins
Sc 4D04DDE3
AR
Op 0 0 0
At SMD
T0 -1300 -50 300 300 900 30 N V 21 N"TSSOP16"
T1 1250 0 300 300 900 50 N V 21 N"VAL***"
DC -815 655 -895 755 60 21
DS 1000 885 1000 -885 60 21
DS 1000 -885 -1000 -885 60 21
DS -1000 -885 -1000 885 60 21
DS -1000 885 1000 885 60 21
$PAD
Sh "1" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -890 1100
$EndPAD
$PAD
Sh "2" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -640 1100
$EndPAD
$PAD
Sh "3" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -380 1100
$EndPAD
$PAD
Sh "4" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -130 1100
$EndPAD
$PAD
Sh "5" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 130 1100
$EndPAD
$PAD
Sh "6" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 385 1100
$EndPAD
$PAD
Sh "7" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 640 1100
$EndPAD
$PAD
Sh "8" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 895 1100
$EndPAD
$PAD
Sh "9" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 895 -1100
$EndPAD
$PAD
Sh "10" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 640 -1100
$EndPAD
$PAD
Sh "11" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 385 -1100
$EndPAD
$PAD
Sh "12" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 130 -1100
$EndPAD
$PAD
Sh "13" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -130 -1100
$EndPAD
$PAD
Sh "14" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -385 -1100
$EndPAD
$PAD
Sh "15" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -640 -1100
$EndPAD
$PAD
Sh "16" R 170 453 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po -895 -1100
$EndPAD
$SHAPE3D
Na "smd/cms_so16.wrl"
Sc 0.250000 0.350000 0.250000
Of 0.000000 0.000000 0.000000
Ro 0.000000 0.000000 0.000000
$EndSHAPE3D
$EndMODULE TSSOP16
$EndLIBRARY
SHAR_EOF
(set 20 10 12 12 15 39 43 'TSSOP16.mod'
eval "${shar_touch}") && \
chmod 0644 'TSSOP16.mod'
if test $? -ne 0
then ${echo} "restore of TSSOP16.mod failed"
fi
if ${md5check}
then (
${MD5SUM} -c >/dev/null 2>&1 || ${echo} 'TSSOP16.mod': 'MD5 check failed'
) << \SHAR_EOF
95df488fa7a2a6b99e9b79c569dfee78 TSSOP16.mod
SHAR_EOF
else
test `LC_ALL wc -c < 'TSSOP16.mod'` -ne 1928 && \
${echo} "restoration warning: size of 'TSSOP16.mod' is not 1928"
fi
fi
if rm -fr ${lock_dir}
then ${echo} "x - removed lock directory ${lock_dir}."
else ${echo} "x - failed to remove lock directory ${lock_dir}."
exit 1
fi
exit 0