#!/bin/bash

export MAIN=/home/OldData/windpowerFcst/NMMV3.2.1
export DATE=$1
tmdat=`date --d="${DATE:0:8} +1day" +%Y%m%d`

$MAIN/scripts/./extractData-AV77.sh $DATE
$MAIN/scripts/./extractData-AV82.sh $DATE
if [ -d $MAIN/outFiles/Anaikadavu/$tmdat'00' ];then
ssh filestransfer@192.168.103.25<<EOF
cd /home/ftpusers/regenpowertech/forecast/Anaikadavu
mkdir -p $tmdat/24hrsforecast
scp -r operational@192.168.103.195:$MAIN/outFiles/Anaikadavu/$tmdat'00'/*.csv $tmdat/24hrsforecast
EOF
else
echo "Data not available.."
fi
exit
