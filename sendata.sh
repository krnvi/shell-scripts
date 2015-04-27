#!/bin/bash
MAIN=/home/OldData/windpowerFcst/NMMV3.2.1
tmdat=20131206
if [ -d $MAIN/outFiles/Anaikadavu/$tmdat'00' ];then
echo "success"
ssh filestransfer@192.168.103.25<<EOF
cd /home/ftpusers/regenpowertech/forecast/Anaikadavu
mkdir -p $tmdat/24hrsforecast
scp -r operational@192.168.103.195:$MAIN/outFiles/Anaikadavu/$tmdat'00'/*.csv $tmdat/24hrsforecast
EOF
exit
else
echo "Data not available.."
fi
