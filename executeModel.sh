#! /bin/bash

export MAIN=/home/OldData/windpowerFcst/NMMV3.2.1
export WRF=$MAIN/WRFV3/test/nmm_real
export WPS=$MAIN/WPS
export WPP=$MAIN/WPPV3
#export INP=/home/Data/WRF-NMM18/input
export INP=/home/operational/input
#export CURDATE=`date -d "-1 day" +%Y%m%d`00
export inputdate=`date +%Y%m%d`
export CURDATE=`date +%Y%m%d`00

#export date=$1
export date=$CURDATE
export STARTDATE=$date
echo $STARTDATE

mkdir -p $MAIN/nmm_output/$STARTDATE

cd $MAIN/namescripts/
$MAIN/namescripts/change_namelist ${STARTDATE} 72

cat namelist.wps.bot >>namelist.wps
cat namelist.input.bot >>namelist.input

cp namelist.wps $WPS/namelist.wps
cp namelist.input $WRF/namelist.input

echo "namelist made"

#***********************************************#
#    Preprocessing GFS data with WPS            #
#***********************************************#

cd $WPS/

#./geogrid.exe

./link_grib.csh $INP/$inputdate/gfs*
./ungrib.exe > ungrib.log
./metgrid.exe > metgrid.log


if [ $? -ne 0 ]; then
    echo metgrid failed
   exit
fi


#***********************************************#
#    Processing WRF ARW core
#***********************************************#

/root/it/skymet_mail_sender.pl vineethpk@skymet.net,anil.kumar@skymetweather.com,basanta.samal@skymetweather.com "Anaikadavu Model started:`hostname`"

cd $WRF/

/opt/installsw/mpich2/bin/mpirun -np 2 ./real_nmm.exe 

if [ `grep -c SUCCESS rsl.out.0000` -lt 1 ]; then
  echo Real run failed
  exit
fi

echo "check wrfbdy_d01 and wrfinput_d01 are made successfully"

/opt/installsw/mpich2/bin/mpirun -np 8 ./wrf.exe 

if [ `grep -c SUCCESS rsl.out.0000` -lt 1 ]; then
  echo WRF failed for ${STARTDATE}
/bin/mail -s "Model failed Anaikadavu: $FINDUSER" $EMAIL_ID < /dev/null
  exit
fi

mv -f wrfout_d01* $MAIN/nmm_output/$STARTDATE/

#***********************************************#
#    Post-Processing WRF Output
#***********************************************#

cd $MAIN/scripts/

$MAIN/scripts/wpp.sh $STARTDATE 1>$MAIN/log/wpprun$STARTDATE.log 2>$MAIN/log/wpperror$STARTDATE.log

cd $WPS
rm -f GRIBFILE.*
rm -f FILE*
cd $WRF
rm wrfinput_d01
rm wrfbdy_d01
rm met_nmm.d01*
rm wrfrst_d01*
exit

