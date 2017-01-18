#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$( cd $(dirname $0); pwd )

if [ $# -lt 2 ]
then
  echo "$0 <date> <product> [ <satellite> ]"
  echo "Need at least two input arguments:"
  echo "- <date> in YYYYMMDD"
  echo "- <product> name: ACC1B, AHK1B, GNV1B, KBR1B"
  echo "Optional argument:"
  echo "- GRACE <satellite>: A or B (default is 'A')"
  echo "NOTICE:"
  echo " - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')"
  exit 1
fi

# parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
DAY=${DATE:6:2}
PRODUCT=$2
if [ $# -lt 3 ]
then
  SAT='A'
else
  SAT=$3
fi
[ "$PRODUCT" == "KBR1B" ] && SAT="X"

#filename stuff
VERSION=02
PREFIX=grace_1B
SUFFIX=.tar.gz

# building package filename
TAR_FILE=$DIR_NOW/L1B/$YEAR/$MONTH/$DAY/${PREFIX}_$YEAR-$MONTH-${DAY}_$VERSION$SUFFIX

# converters
CONV=$(find $DIR_NOW/software/ -name Bin2AsciiLevel1.e | sort | tail -n1)

# checking if data was already downloaded
if [ ! -e "$TAR_FILE" ]
then
  # need to get it
  $DIR_NOW/download-l1b.sh $DATE
fi

if [ ! -e "$TAR_FILE" ]
then
  echo "Cannot find file '$TAR_FILE'."
  exit 3
fi

# extracting
DIR_HERE=$(dirname $TAR_FILE)
mkdir -p $DIR_HERE
tar -xvmzkq -f "$TAR_FILE" -C "$DIR_HERE" \
--exclude=CLK1B* \
--exclude=GPS1B* \
--exclude=IHK1B* \
--exclude=MAG1B* \
--exclude=MAS1B* \
--exclude=SCA1B* \
--exclude=TDP1B* \
--exclude=THR1B* \
--exclude=TIM1B* \
--exclude=TNK1B* \
--exclude=USO1B* \
--exclude=VSL1B*

$CONV -binfile $DIR_HERE/${PRODUCT}_$YEAR-$MONTH-${DAY}_${SAT}_$VERSION.dat



