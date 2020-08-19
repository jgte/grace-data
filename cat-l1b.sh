#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$( cd $(dirname $0); pwd )

#default data characteristics
SAT='A'
VERSION=02
SOURCE=JPL


if [ $# -lt 1 ]
then
  echo "$0 [ <date> <product> [ <sat> [ <version> [ <source> ] ] ] | <dat file> ]"
  echo
  echo "Either:"
  echo "  - <date> in YYYYMMDD"
  echo "  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TIM1B, TNK1B, USO1B, VSL1B"
  echo "  Optional argument:"
  echo "   - sat     : GRACE A or B, defaults to '$SAT' (irrelevant if <product> is 'KBR1B')"
  echo "   - version : release versions, defaults to '$VERSION'"
  echo "   - source  : data source institute, defaults to '$SOURCE'"
  echo "  NOTICE:"
  echo "   - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')"
  echo
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
  if [ "${#DATE}" -ne 8 ]
  then
    echo "ERROR: expecting date to be in YYYYMMDD format, with length equal to 8, not ${#DATE}."
    exit 3
  fi
  YEAR=${DATE:0:4}
  MONTH=${DATE:4:2}
  DAY=${DATE:6:2}
  PRODUCT=$2
  case $2 in
    ACC1B|AHK1B|GNV1B|KBR1B|MAS1B|SCA1B|THR1B|CLK1B|GPS1B|IHK1B|MAG1B|TIM1B|TNK1B|USO1B|VSL1B)
      PRODUCT=$2;;
    *)
      echo "ERROR: cannot understand product $2"
      exit 3;;
  esac
  [ $# -ge 3 ] && SAT="$3"
  [ $# -ge 4 ] && VERSION="$4"
  [ $# -ge 5 ] && SOURCE="$5"
  [ "$PRODUCT" == "KBR1B" ] && SAT="X"
  # extract file from archive
  $DIR_NOW/extract-l1b.sh $@ 1>&2 || exit $?
  # building package filename
  LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/
  DAT_FILE=$LOCALDIR/${PRODUCT}_$YEAR-$MONTH-${DAY}_${SAT}_$VERSION.dat
fi

if [ ! -e "$DAT_FILE" ]
then
  echo "Cannot find file '$DAT_FILE'."
  exit 3
fi

#show contents
$CONV -binfile $DAT_FILE

rm -f $DAT_FILE

