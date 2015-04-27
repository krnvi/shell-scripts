#!/bin/bash
rm -fr header.txt temp.txt F_write.gs
i=i
#CDT=`date +%Y%m%d`
export STARTDATE=$1
CDT=$STARTDATE
SDY=${CDT:0:4}
SDM=${CDT:4:2}
SDD=${CDT:6:2}
SDT=$SDM\/$SDD\/$SDY
D1=`date -d "$SDT +$i days" +%Y%m%d`
D1Y=${D1:0:4}
D1M=${D1:4:2}
D1D=${D1:6:2}
export DATE=$1
SY=${DATE:0:4}
SM=${DATE:4:2}
SD=${DATE:6:2}
DT=$SM\/$SD\/$SY
echo $DT
Day1=`date -d "$DT +0 days" +%Y%m%d`
export YY=${Day1:0:4}
export MM=${Day1:4:2}
export DD=${Day1:6:2}
DT1=$YY\/$MM\/$DD
echo $DT1
Day2=`date -d "$DT +1 days" +%Y%m%d`
export YY=${Day2:0:4}
export MM=${Day2:4:2}
export DD=${Day2:6:2}
DT2=$YY\/$MM\/$DD
echo $DT2
Day3=`date -d "$DT +2 days" +%Y%m%d`
export YY=${Day3:0:4}
export MM=${Day3:4:2}
export DD=${Day3:6:2}
DT3=$YY\/$MM\/$DD
echo $DT3

export main=/home/OldData/windpowerFcst/NMMV3.2.1
export outFiles=$main/outFiles/Anaikadavu
export scripts=$main/scripts
export wpp=$main/WPPV3/rrun/poutpost
export date=$1

mkdir -p $outFiles/$date
cd $outFiles/$date

ln -sf $scripts/anaikadavu.lst masterlist
ln -sf $wpp/$date/wrfpost$date.ctl ./wrfpost$date.ctl
ln -sf $wpp/$date/wrfpost$date.idx ./wrfpost$date.idx
ln -sf $wpp/$date/wrfpost$date ./wrfpost$date

cat masterlist | while IFS=, read ID FNAME LAT LON; do
echo "File:$FNAME LAT:$LAT LON:$LON"
export FILENAME=$FNAME.csv
############################## WRF-ARW Header################
#echo "Level-700,Level-750,Level-800,Level-850,Level-875,Level-900,Level-910,Level-920,Level-930,Level-940,Level-950,Level-960,Level-980" > header.txt
############################## WRF-NMM Header################
echo "Date,Time(GMT),Level-600,Level-650,Level-700,Level-750,Level-775,Level-800,Level-825,Level-850,Level-875,Level-900,Level-925,Level-950,Level-975" > header.txt
cat << EOF > F_write.gs
*//////////////////////////////////////////////////////////////////////
*//////////////////////////////////////////////////////////////////////
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

hilon = $LON
hilat = $LAT
dat1  = "$DT1"
dat2  = "$DT2"
'reinit'
'clear'
'open wrfpost$date.ctl'
* Find the grid point closest to requsted location
 'q file'
 lin = sublin(result,1)
 _fnu=subwrd(lin,2)
 'q file '_fnu
 lin = sublin(result,5)
 _npx=subwrd(lin,3)
 _npy=subwrd(lin,6)
 _llon=hilon
 _llat=hilat

tt=1
mi=00
hh=00
_var=UGRDprs 
say _llon' ' _llat' ' _var

while(tt<193)
'set grads off'
'set lat 'hilat
'set lon 'hilon
'set t 'tt

'set z 14'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws14= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws14'
rec14=sublin(result,1)
ws14=subwrd(rec14,4)

'set z 13'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws13= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws13'
rec13=sublin(result,1)
ws13=subwrd(rec13,4)

'set z 12'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws12= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws12'
rec12=sublin(result,1)
ws12=subwrd(rec12,4)

'set z 11'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws11= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws11'
rec11=sublin(result,1)
ws11=subwrd(rec11,4)

'set z 10'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws10= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws10'
rec10=sublin(result,1)
ws10=subwrd(rec10,4)

'set z 9'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws9= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws9'
rec9=sublin(result,1)
ws9=subwrd(rec9,4)

'set z 8'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws8= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws8'
rec8=sublin(result,1)
ws8=subwrd(rec8,4)

'set z 7'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws7= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws7'
rec7=sublin(result,1)
ws7=subwrd(rec7,4)

'set z 6'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws6= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws6'
rec6=sublin(result,1)
ws6=subwrd(rec6,4)

'set z 5'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws5= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws5'
rec5=sublin(result,1)
ws5=subwrd(rec5,4)

'set z 4'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws4= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws4'
rec4=sublin(result,1)
ws4=subwrd(rec4,4)

'set z 3'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws3= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws3'
rec3=sublin(result,1)
ws3=subwrd(rec3,4)

'set z 2'
_var=UGRDprs
val1=interp_stn()
_var=VGRDprs
val2=interp_stn()
'define ws2= sqrt('val1'*'val1'+'val2'*'val2')'
'd ws2'
rec2=sublin(result,1)
ws2=subwrd(rec2,4)


if(mi>51)
mi=00
hh=hh+1
if(hh>23)
hh=00
endif
endif

if(tt<96)
day=dat1
endif
if(tt>96&tt<193)
day=dat2
endif

'!echo 'day','hh':'mi','ws14','ws13','ws12','ws11','ws10','ws9','ws8','ws7','ws6','ws5','ws4','ws3','ws2' >>' temp.txt
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
*//////////////////////////////////////////////////////////////
EOF
/opt/installsw/grads-2.0.1/bin/grads -blcx F_write.gs
echo $FNAME "Completed"
cat header.txt temp.txt >$FNAME"-"$date.csv
#mv $FNAME"-"$date.csv $outFiles/$date
rm -fr header.txt temp.txt F_write.gs
done
rm -fr wrfpost$date* masterlist
exit
