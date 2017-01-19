#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$( cd $(dirname $0); pwd )

if [ $# -lt 1 ]
then
  echo "$0 [ <date> <product> [ <satellite> ] | <dat file> ]"
  echo "Need at least one input arguments."
  echo "Either:"
  echo "  - <date> in YYYYMMDD"
  echo "  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, NAVSOL, SCAATT, THRDAT"
  echo "  Optional argument:"
  echo "   - GRACE <satellite>: A or B (default is 'A')"
  echo "  NOTICE:"
  echo "   - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')"
  echo "Or:"
  echo "  - <dat file>, with complete path"
  exit 1
fi

# converter
CONV=$(find $DIR_NOW/software/ -name Bin2AsciiLevel1.e | sort | tail -n1)

# parsing inputs
if [ $# -eq 1 ]
then
   DAT_FILE="$1"
else
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
  # building package filename
  DAT_FILE=$(ls $DIR_NOW/L1B/$YEAR/$MONTH/$DAY/${PRODUCT}_$YEAR-$MONTH-${DAY}_${SAT}_*.dat | tail -n1)
fi

# checking if data was already downloaded and expanded
if [ ! -e "$DAT_FILE" ]
then
  # need to get it
  $DIR_NOW/download-l1b.sh $DATE || exit $?
fi

$CONV -binfile $DAT_FILE



