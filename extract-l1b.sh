#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

if [ $# -lt 2 ]
then
  echo "$0 <date> <product>"
  echo "Need two input arguments."
  echo "  - <date> in YYYYMMDD"
  echo "  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TDP1B, TIM1B, TNK1B, USO1B, VSL1B"
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

#archive name stuff
PREFIX=grace_1B
SUFFIX=.tar.gz
# building package filename and pick the most recent version
TAR_FILE=$(ls $DIR_NOW/L1B/$YEAR/${PREFIX}_$YEAR-$MONTH-${DAY}_*$SUFFIX 2> /dev/null | tail -n1)

if [ ! -e "$TAR_FILE" ]
then
  # need to get it
  $DIR_NOW/download-l1b.sh $DATE || exit $?
  # re-building package filename and pick the most recent version
  TAR_FILE=$(ls $DIR_NOW/L1B/$YEAR/${PREFIX}_$YEAR-$MONTH-${DAY}_*$SUFFIX 2> /dev/null | tail -n1)
fi

if [ ! -e "$TAR_FILE" ]
then
  echo "Cannot find file '$DIR_NOW/L1B/$YEAR/${PREFIX}_$YEAR-$MONTH-${DAY}_*$SUFFIX'."
  exit 3
fi

# extracting
tar -xvmzk -f "$TAR_FILE" -C "$(dirname $TAR_FILE)" --include=$PRODUCT*_${SAT}_*.dat || exit $?
