#!/bin/bash
export MAIN=/home/Data/powerRun/NMMV3.2.1/
export OUTPATH=/home/OldData/AnaikadavuSetupAndData/powerModelOutput/06gmt
export SCRIPTS=$MAIN/scripts/
export WPP=$MAIN/WPPV3/rrun/poutpost/
export DATE=$1

mkdir -p $OUTPATH/$DATE
cd $OUTPATH/$DATE/
ln -sf $SCRIPTS/anaikadavu.lst masterlist
ln -sf $WPP/$DATE/wrfpost$DATE.ctl wrfpost$DATE.ctl
ln -sf $WPP/$DATE/wrfpost$DATE.idx wrfpost$DATE.idx
ln -sf $WPP/$DATE/wrfpost$DATE wrfpost$DATE

mm=`echo $DATE|cut -c5-6`
cat masterlist | while IFS=, read ID STNNAME LAT LON; do

export FILENAME=$STNNAME"-"$DATE.csv
DT=`date -d "-1 day" +%Y/%m/%d`
DT1=`date -d "0days" +%Y/%m/%d`
DT2=`date -d "1days" +%Y/%m/%d`
DT3=`date -d "2days" +%Y/%m/%d`
DT4=`date -d "3days" +%Y/%m/%d`
DT5=`date -d "4days" +%Y/%m/%d`
DT6=`date -d "5days" +%Y/%m/%d`
DT7=`date -d "6days" +%Y/%m/%d`
DT8=`date -d "7days" +%Y/%m/%d`

cat << EOF > Tatak01.gs
*//////////////////////////////////////////////////////////////////////
*//////////////////////////////////////////////////////////////////////
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
  name  = $STNNAME
  mn=$mm
  hilon = $LON
  hilat = $LAT
  tim   ="$DT"
 dat1="day1"
 dat2="day2"
 dat3="day3"
 dat4="day4"
 date1 ="$DT1"
 date2 ="$DT2"
 date3 ="$DT3"
 date4 ="$DT4"
 date5 ="$DT5"
 date6 ="$DT6"
 date7 ="$DT7"
 date8 ="$DT8"
 dat5  ="day5"
 dat6  ="day6"
 dat7  ="day7"
 dat8  ="day8"

'reinit'
'open wrfpost$DATE.ctl'

**
'!echo "DATE,TIME(IST),WINDspd(m/s),WINDdir(degree),Power(KW)">'tat1.csv
tt=51
hh=00
mi=00

while(tt<384)
'set grads off'
'set lat 'hilat
'set lon 'hilon
'set t 'tt

'set z 2'
'define ws = (mag(UGRDprs,VGRDprs))'
'define p1=2174.93*(exp(-exp(1.78534-(0.199578*ws))))'
'd ws'
rec3=sublin(result,1)
wsp=subwrd(rec3,4)
fmt= '%4.2f'
wspd=math_format(fmt,wsp)
'd ws'
rec3=sublin(result,1)
wsp=subwrd(rec3,4)
fmt= '%4.2f'
wspd1=math_format(fmt,wsp)

'd p1'
rec3=sublin(result,1)
pow=subwrd(rec3,4)
fmt= '%5.2f'
power=math_format(fmt,pow)


'define wdir = 270 -(atan2(VGRDprs,UGRDprs))*180*7/22'
'd wdir'
rec4=sublin(result,1)
inter1=subwrd(rec4,4)
if(inter1>360)
inter1=inter1-360
else
inter1=subwrd(rec4,4)
endif
fmt= '%3.2f'
wdir=math_format(fmt,inter1)

#TATAK-01: A = 23.1666, B= 1.04603, C=0.177834
#TATAK-02: A = 1690.27, B=2.4138, C=0.287089

if(mi>50)
mi=00
hh=hh+1
if(hh>23)
hh=00
endif
endif

if(tt<146)
day=dat1
endif
if(tt>146&tt<242)
day=dat2
endif
if(tt>242&tt<338)
day=dat3
endif
if(tt>338)
day=dat4
endif
if(tt>434&tt<530)
day=dat5
endif
if(tt>530&tt<626)
day=dat6
endif
if(tt>626&tt<722)
day=dat7
endif
if(tt>722)
day=dat8
endif


if(tt<146)
ti=date1
endif
if(tt>146&tt<242)
ti=date2
endif
if(tt>242&tt<338)
ti=date3
endif
if(tt>338)
ti=date4
endif
if(tt>434&tt<530)
ti=date5
endif
if(tt>530&tt<626)
ti=date6
endif
if(tt>626&tt<722)
ti=date7
endif
if(tt>722)
ti=date8
endif

'!echo 'ti','hh':'mi','wspd','wdir','power'>>' tat1.csv
tt=tt+1
mi=mi+15
endwhile

'quit'
EOF
/opt/installsw/grads-2.0.1/bin/grads -bp -cx Tatak01.gs
mv tat1.csv $FILENAME

#sed -n 1,1p tat1.csv > /tmp/tat1
#sed -n 98,383p tat1.csv >> /tmp/tat1
#mv /tmp/tat1 $MAIN/Clients/$DATE/$FILENAME1
echo $STNNAME "Completed"
done
rm Tatak01.gs wrfpost* masterlist
exit
