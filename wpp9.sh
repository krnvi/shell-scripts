#!/bin/ksh
#
set -x

# August 2005: Hui-Ya Chuang, NCEP: This script uses 
# NCEP's WRF-POSTPROC to post processes WRF native model 
# output, and uses copygb to horizontally interpolate posted 
# output from native A-E to a regular projection grid. 
#
# July 2006: Meral Demirtas, NCAR/DTC: Added new "copygb" 
# options and revised some parts for clarity. 
#
#--------------------------------------------------------
# This script performs 2 jobs:
#
# 1. Run WRF-POSTPROC
# 2. Run copygb to horizontally interpolate output from 
#    native A-E to a regular projection grid
#--------------------------------------------------------

# Set path to your top directory and your run dorectory 
#

export TOP_DIR=/home/OldData/windpowerFcst/NMMV3.2.1
export DOMAINPATH=${TOP_DIR}/WPPV3/rrun
export NPRD=${DOMAINPATH}/postprd
export MOVDIR=${DOMAINPATH}/poutput
#Specify Dyn Core (ARW or NMM in upper case)
dyncore="NMM"

if [ $dyncore = "NMM" ]; then
   export tag=NMM
elif [ $dyncore = "ARW" ]; then
   export tag=NCAR
else
    echo "${dyncore} is not supported. Edit script to choose ARW or NMM dyncore."
    exit
fi



# Specify forecast start date
# fhr is the first forecast hour to be post-processed
# lastfhr is the last forecast hour to be post-processed
# incrementhr is the incement (in hours) between forecast files

export startdate=$1

export fhr=97
export lastfhr=108
export incrementhr=01
export incrementmin=15
export lastmin=59

# Path names for WRF_POSTPROC and WRFV3

export WRF_POSTPROC_HOME=${TOP_DIR}/WPPV3
export POSTEXEC=${WRF_POSTPROC_HOME}/exec
export SCRIPTS=${WRF_POSTPROC_HOME}/scripts
export WRFPATH=${TOP_DIR}/WRFV3

# cd to working directory
cd ${DOMAINPATH}/postprd9


# Link Ferrier's microphysic's table and WRF-POSTPROC control file, 

ln -fs ${WRFPATH}/run/ETAMPNEW_DATA eta_micro_lookup.dat
ln -fs ${DOMAINPATH}/parm/wrf_cntrl.parm .

export tmmark=tm00
export MP_SHARED_MEMORY=yes
export MP_LABELIO=yes

#######################################################
# 1. Run WRF-POSTPROC 
#
# The WRF-POSTPROC is used to read native WRF model 
# output and put out isobaric state fields and derived fields.
#
#######################################################

pwd
ls -x

export NEWDATE=$startdate

while [ $fhr -le $lastfhr ] ; do

typeset -Z3 fhr

NEWDATE=`${POSTEXEC}/ndate.exe +${fhr} $startdate`

YY=`echo $NEWDATE | cut -c1-4`
MM=`echo $NEWDATE | cut -c5-6`
DD=`echo $NEWDATE | cut -c7-8`
HH=`echo $NEWDATE | cut -c9-10`

echo 'NEWDATE' $NEWDATE
echo 'YY' $YY
export min=00

while [ $min -le $lastmin ] ; do

#for domain in d01 d02 d03
for domain in d01
do

cat > itag <<EOF
$TOP_DIR/nmm_output/$1/wrfout_${domain}_${YY}-${MM}-${DD}_${HH}:${min}:00
netcdf
${YY}-${MM}-${DD}_${HH}:${min}:00
${tag}
EOF

#-----------------------------------------------------------------------
#   Run wrfpost.
#-----------------------------------------------------------------------
#rm fort.*

ln -sf wrf_cntrl.parm fort.14
ln -sf griddef.out fort.110
/opt/installsw/mpich2/bin/mpirun -np 1 ${POSTEXEC}/wrfpost.exe < itag >  wrfpost_${domain}.$fhr_${min}.out 2>&1

if [ $min = 00 ]; then
mv WRFPRS$fhr.tm00 WRFPRS_${domain}.${fhr}_${min}
else
mv WRFPRS${fhr}:${min}.tm00 WRFPRS_${domain}.${fhr}_${min}
fi
#
#----------------------------------------------------------------------
#   End of wrf post job
#----------------------------------------------------------------------

ls -l WRFPRS_${domain}.${fhr}_${min}
err1=$?

if test "$err1" -ne 0
then

echo 'WRF POST FAILED, EXITTING'
exit

fi

if [ $dyncore = "NMM" ]; then



#######################################################################
# 2. Run copygb
# 
# Copygb interpolates WRF-POSTPROC output from its native 
# grid to a regular projection grid. The package copygb 
# is used to horizontally interpolate from one domain 
# to another, it is necessary to run this step for wrf-nmm 
# (but not for wrf-arw) because wrf-nmm's computational 
# domain is on rotated Arakawa-E grid
#
# Copygb can be run in 3 ways as explained below. 
# Uncomment the preferable one.
#
#----------------------------------------------------------------------
#
# Option 1: 
# Copygb is run with a pre-defined AWIPS grid 
# (variable $gridno, see below) Specify the grid to 
# interpolate the forecast onto. To use standard AWIPS grids 
# (list in  http://wwwt.emc.ncep.noaa.gov/mmb/namgrids/ or 
# or http://www.nco.ncep.noaa.gov/pmb/docs/on388/tableb.html),
# set the number of the grid in variable gridno below.
# To use a user defined grid, see explanation above copygb.exe command.
#
# export gridno=212
#
#${POSTEXEC}/copygb.exe -xg${gridno} WRFPRS_${domain}.${fhr} wrfprs_${domain}.${fhr}
#
#----------------------------------------------------------------------
#
#  Option 2: 
#  Copygb ingests a kgds definition on the command line.
#${POSTEXEC}/copygb.exe -xg"255 3 109 91 37748 -77613 8 -71000 10379 9900 0 64 42000 42000" WRFPRS_${domain}.${fhr} wrfprs_${domain}.${fhr}
#
#----------------------------------------------------------------------
#
#  Option 3: 
#  Copygb can ingests contents of files too. For example:
#     copygb_gridnav.txt or copygb_hwrf.txt through variable $nav.
# 
#  Option -3.1:
#    To run for "Lambert Comformal map projection" uncomment the following line
#
# read nav < 'copygb_gridnav.txt'
#
#  Option -3.2:
#    To run for "lat-lon" uncomment the following line 
#
read nav < 'copygb_hwrf.txt'
#
export nav
#
/opt/installsw/mpich2/bin/mpirun -np 1 ${POSTEXEC}/copygb.exe -xg"${nav}" WRFPRS_${domain}.${fhr}_$min wrfprs_${domain}.${fhr}_${min} >copygb.log
#
# (For more info on "copygb" see WRF-NMM User's Guide, Chapter-7.)
#----------------------------------------------------------------------

# Check to see whether "copygb" created the requested file.

ls -l wrfprs_${domain}.${fhr}_${min}
err1=$?

if test "$err1" -ne 0
then

echo 'copygb FAILED, EXITTING'
exit

fi

#----------------------------------------------------------------------
#   End of copygb job
#----------------------------------------------------------------------

elif [ $dyncore = "ARW" ]; then
    ln -s WRFPRS_${domain}.${fhr}_$min wrfprs_${domain}.${fhr}_${min}
fi

done

let "min=min+$incrementmin"
done
let "fhr=fhr+$incrementhr"


NEWDATE=`${POSTEXEC}/ndate.exe +${fhr} $startdate`

done

date
echo "End of Output Job"
mv wrfprs_d01* ${NPRD}/



#cd $NPRD
#cat wrfprs_d01* > all
#grib2ctl.pl -verf all>all.ctl
#gribmap -i all.ctl
#mv all* $MOVDIR
#cd $NPRD
#rm *
exit
