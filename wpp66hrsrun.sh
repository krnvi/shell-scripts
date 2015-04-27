#!/bin/bash

export MAIN=/home/OldData/windpowerFcst/NMMV3.2.1
export WPP=$MAIN/WPPV3
export WPPOUT=$WPP/rrun/poutpost
export DOM=$MAIN/WPPV3/rrun/postprd

rm -f ${DOM}/postprd*/*

export DATE=$1
tmdat=`date --d="${DATE:0:8} +1day" +%Y%m%d`
mkdir -p $WPPOUT/$DATE

cd $MAIN/scripts/

./wpp1.sh $DATE > $MAIN/log/wpp1.log & 
./wpp2.sh $DATE > $MAIN/log/wpp2.log & 
./wpp3.sh $DATE > $MAIN/log/wpp3.log &
./wpp4.sh $DATE > $MAIN/log/wpp4.log &
./wpp6hrsrun.sh $DATE > $MAIN/log/wpp6.log 
./wpp5.sh $DATE > $MAIN/log/wpp5.log &
#./wpp8.sh $DATE > $MAIN/log/wpp7.log &
#./wpp7.sh $DATE > $MAIN/log/wpp8.log 
#./wpp9.sh $DATE > $MAIN/log/wpp9.log &
#./wpp10.sh $DATE > $MAIN/log/wpp10.log &
#./wpp11.sh $DATE > $MAIN/log/wpp11.log &
#./wpp12.sh $DATE > $MAIN/log/wpp12.log &
#./wpp13.sh $DATE > $MAIN/log/wpp13.log &
#./wpp14.sh $DATE > $MAIN/log/wpp14.log &
#./wpp16.sh $DATE > $MAIN/log/wpp15.log &
#./wpp15.sh $DATE > $MAIN/log/wpp16.log

sleep 180

cd ${DOM}

FIL=0
FIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
FIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
FIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
FIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
FIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
FFIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
FIL=`ls wrfprs*|wc -l`
if [ $FIL -lt 267 ]; then
sleep 300
exit
fi
fi
fi
fi
fi
fi
fi

#echo "End of Output Job"

cat wrfprs_d01* > wrfpost66hrs$DATE

/opt/installsw/grads-2.0.1/bin/grib2ctl.pl -verf wrfpost66hrs$DATE > wrfpost66hrs$DATE.ctl

cat wrfpost66hrs$DATE.ctl | sed -e 's/tdef 66/tdef 267/' | sed -e 's/1hr/15mn/' > all.ctl
mv all.ctl wrfpost66hrs$DATE.ctl
/opt/installsw/grads-2.0.1/bin/gribmap -big -i wrfpost66hrs$DATE.ctl
mv wrfpost66hrs* $WPPOUT/$DATE/
echo "all is generated and moved to poutpost folder"
rm -f ${DOM}/*
rm -r $MAIN/nmm_output/$DATE
/root/it/skymet_mail_sender.pl vineethpk@skymet.net,anil.kumar@skymetweather.com,basanta.samal@skymetweather.com "Anaikadavu Model finised:`hostname`"
#$MAIN/scripts/./extractData-AV77.sh $DATE
#$MAIN/scripts/./extractData-AV82.sh $DATE
#cd $WPPOUT
#gzip -rf $DATE
#if [ -d $MAIN/outFiles/Anaikadavu/$DATE ];then
#ssh filestransfer@192.168.103.25<<EOF
#cd /home/ftpusers/regenpowertech/forecast/Anaikadavu
#mkdir -p $tmdat/24hrsforecast
#scp -r operational@192.168.103.195:$MAIN/outFiles/Anaikadavu/$tmdat'00'/*.csv $tmdat/24hrsforecast
#EOF
#exit
#else
#echo "Data not available.."
#fi
exit
