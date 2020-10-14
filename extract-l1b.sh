#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)
#constants: filename stuff
PREFIX=grace_1B

#default data characteristics
SAT='A'
VERSION=03
SOURCE=JPL

if [ $# -lt 2 ]
then
  echo "\
extract-l1b.sh <date> <product> [ <sat> [ <version> [ <source> ] ] ]

 - <date> in YYYYMM
 - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TDP1B, TIM1B, TNK1B, USO1B, VSL1B

Optional inputs:
 - sat     : GRACE A or B, defaults to '$SAT' (irrelevant if <product> is 'KBR1B')
 - version : release versions, defaults to '$VERSION'
 - source  : data source institute, defaults to '$SOURCE'
 NOTICE: v03 data is available in monthly files; all other versions are available in daily files"
  exit 1
fi

# parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
PRODUCT=$2
[ $# -ge 3 ] && SAT="$3"
[ $# -ge 4 ] && VERSION="$4"
[ $# -ge 5 ] && SOURCE="$5"
[ "$PRODUCT" == "KBR1B" ] && SAT="X"
# building package filename
if [ "$VERSION" == "03" ]
then
  TAR_FILE=${PREFIX}_$YEAR-${MONTH}_$VERSION.tgz
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}_$VERSION.dat
  MSG="Extracting v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH: $TAR_FILE"
else
  DAY=${DATE:6:2}
  TAR_FILE=${PREFIX}_$YEAR-${MONTH}-${DAY}_$VERSION.tar.gz
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_$VERSION.dat
  MSG="Extracting v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH-$DAY: $TAR_FILE"
fi
#define local coordinates
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/$YEAR

#make sure tar file is available
[ -e "$LOCALDIR/$TAR_FILE" ] || $DIR_NOW/download-l1b.sh $DATE $VERSION $SOURCE || exit $?
#double check
if [ ! -e "$LOCALDIR/$TAR_FILE" ]
then
  echo "ERROR:extract-l1b.sh: Cannot find file '$TAR_FILE'."
  exit 3
fi

if [ -e "$LOCALDIR/$DAT_FILE" ]
then
  echo "Already extracted $DAT_FILE"
else
  echo "$MSG"
  # extracting
  tar -xvmzk -f "$LOCALDIR/$TAR_FILE" -C "$LOCALDIR" --include=$PRODUCT*_${SAT}_*.dat || exit $?
fi