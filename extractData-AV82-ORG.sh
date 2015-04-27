#!/bin/bash

export main=/home/OldData/windpowerFcst/NMMV3.2.1
export outFiles=$main/outFiles/Anaikadavu/82
export scripts=$main/scripts
export wpp=$main/WPPV3/rrun/poutpost
export date=$1

mkdir -p $outFiles/$date
cd $outFiles/$date

ln -sf $scripts/anaikadavu82.lst masterlist
ln -sf $WPP/$date/wrfpost$date.ctl ./wrfpost$date.ctl
ln -sf $WPP/$date/wrfpost$date.idx ./wrfpost$date.idx
ln -sf $WPP/$date/wrfpost$date ./wrfpost$date

yr=${date:0:4}
mt=${date:4:2}
dd=${date:6:2}
hh=${date:8:2}

if [ $hh -eq 00 ] ; then
stme=75
fi
if [ $hh -eq 06 ] ; then
stme=51
fi
if [ $hh -eq 12 ] ; then
stme=27
fi
if [ $hh -eq 18 ] ; then
stme=3
fi

DT=`date -d "$yr$mt$dd -1 day" +%Y/%m/%d`
DT1=`date -d "$yr$mt$dd 0 days" +%Y/%m/%d`
DT2=`date -d "$yr$mt$dd 1 days" +%Y/%m/%d`
DT3=`date -d "$yr$mt$dd 2 days" +%Y/%m/%d`
DT4=`date -d "$yr$mt$dd 3 days" +%Y/%m/%d`
DT5=`date -d "$yr$mt$dd 4 days" +%Y/%m/%d`
DT6=`date -d "$yr$mt$dd 5 days" +%Y/%m/%d`
DT7=`date -d "$yr$mt$dd 6 days" +%Y/%m/%d`
DT8=`date -d "$yr$mt$dd 7 days" +%Y/%m/%d`


cat masterlist | while IFS=, read ID STNNAME LAT LON; do
export fileName=$STNNAME"-"$date.csv

cat << EOF > temp.gs

*//////////////////////////////////////////////////////////////////////
*//////////////////////////////////////////////////////////////////////
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
  name  = $STNNAME
  mn    =$mt
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
'open wrfpost$date.ctl'

 'q file'
 lin = sublin(result,1)
 _fnu=subwrd(lin,2)
 'q file '_fnu
 lin = sublin(result,5)
 _npx=subwrd(lin,3)
 _npy=subwrd(lin,6)
 _llon=hilon
 _llat=hilat

**
'!echo "DATE,TIME(IST),WINDspd(m/s),WINDdir(degree),Power(KW)">'tat1.csv
tt=$stme
hh=00
mi=00

_var=UGRDprs 
say _llon' ' _llat' ' _var


while(tt<193)
'set grads off'
'set lat 'hilat
'set lon 'hilon
'set t 'tt
'set z 2'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()

'define ws= sqrt('val1'*'val1'+'val2'*'val2')'
*'define p1=2174.93*(exp(-exp(1.78534-(0.199578*ws))))'

'd ws'
rec3=sublin(result,1)
wsp=subwrd(rec3,4)
fmt= '%4.2f'
wspd=math_format(fmt,wsp)

if (wspd<3)
'define p1=0'
endif
if (wspd>3&wspd<5)
'define p1=(66.56*'wspd')-177.1'
else
'define p1=1519.12/pow((1+exp(10.19-1.12*'wspd')),(1/2.14))'
endif

'd p1'
rec3=sublin(result,1)
pow=subwrd(rec3,4)
fmt= '%5.2f'
power=math_format(fmt,pow)

'define val= 270 -(atan2('val1','val2'))*180*7/22'
'd val'
rec4=sublin(result,1)
inter1=subwrd(rec4,4)
if(inter1>360)
inter1=inter1-360
else
inter1=subwrd(rec4,4)
endif
fmt= '%3.2f'
wdir=math_format(fmt,inter1)


if(mi>50)
mi=00
hh=hh+1
if(hh>23)
hh=00
endif
endif

f($stme=75)
if(tt<170)
day=dat1
ti=date1
endif
if(tt>170&tt<266)
day=dat2
ti=date2
endif
if(tt>266)
day=dat3
ti=date3
endif
endif

if($stme=51)
if(tt<146)
day=dat1
ti=date1
endif
if(tt>146&tt<242)
day=dat2
ti=date2
endif
if(tt>242)
day=dat3
ti=date3
endif
endif

if($stme=27)
if(tt<122)
day=dat1
ti=date1
endif
if(tt>122&tt<218)
day=dat2
ti=date2
endif
if(tt>218)
day=dat3
ti=date3
endif
endif

if($stme=3)
if(tt<98)
day=dat1
ti=date1
endif
if(tt>98&tt<194)
day=dat2
ti=date2
endif
if(tt>194)
day=dat3
ti=date3
endif
endif

'!echo 'ti','hh':'mi','wspd','wdir','power' >>' dat.csv
tt=tt+1
mi=mi+15
endwhile

***********Interpolation Function*********************

function interp_stn()
if(_var='' | _llon='' | _llat='')
 say 'interp_stn stoped'; return
endif
* say _var' '_llon' '_llat
'set dfile '_fnu
'set x 1 '_npx
'set y 1 '_npy
'd '_var
'q w2gr '_llon' '_llat
xdim=subwrd(result,3)
xdim=0.+xdim
if ( xdim <=  1.) ; xdim=_npx+xdim ; endif
ydim=subwrd(result,6)
* nearest x dimensions :
x1= math_int(xdim)
x2 = x1 + 1
* the weights are
xw1= xdim-x1
xw2= 1.-xw1
* nearest y dimensions :
y1= math_int(ydim)
y2 = y1 + 1
* the weights are
yw1= ydim-y1
yw2= 1.-yw1

f11=gpv(_var,x1,y1)
f21=gpv(_var,x2,y1)
f12=gpv(_var,x1,y2)
f22=gpv(_var,x2,y2)

station = f11*xw2*yw2 + f21*xw1*yw2 + f12*xw2*yw1 + f22*xw1*yw1

return(station)

function gpv(v,x,y)
*get grid point value of field "v"
'set x 'x 
'set y 'y
'd 'v
val=subwrd(result,4)
return(val)

**************************************************************
'set grads off'
'quit'
EOF
/opt/installsw/grads-2.0.1/bin/grads -bp -cx temp.gs
mv dat.csv $fileName
echo $STNNAME "Completed"
done
rm *.gs wrfpost* masterlist
exit
