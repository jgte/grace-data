#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

#default data characteristics
SAT='A'
VERSION=02
SOURCE=JPL

if [ $# -lt 2 ]
then
  echo "$0 <date> <product> [ <sat> [ <version> [ <source> ] ] ]"
  echo "Need two input arguments."
  echo "  - <date> in YYYYMMDD"
  echo "  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TDP1B, TIM1B, TNK1B, USO1B, VSL1B"
  echo
  echo "Optional inputs:"
  echo " - sat     : GRACE A or B, defaults to '$SAT' (irrelevant if <product> is 'KBR1B')"
  echo " - version : release versions, defaults to '$VERSION'"
  echo " - source  : data source institute, defaults to '$SOURCE'"

  exit 1
fi

# parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
DAY=${DATE:6:2}
PRODUCT=$2
[ $# -ge 3 ] && SAT="$3"
[ $# -ge 4 ] && VERSION="$4"
[ $# -ge 5 ] && SOURCE="$5"
[ "$PRODUCT" == "KBR1B" ] && SAT="X"

#archive name stuff
PREFIX=grace_1B
SUFFIX=.tar.gz
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/
# building package filename
TAR_FILE=$LOCALDIR/${PREFIX}_$YEAR-$MONTH-${DAY}_$VERSION$SUFFIX
#make sure it is available
[ -e "$TAR_FILE" ] || $DIR_NOW/download-l1b.sh $DATE $VERSION $SOURCE || exit $?
#double check
if [ ! -e "$TAR_FILE" ]
then
  echo "Cannot find file '$TAR_FILE'."
  exit 3
fi

# extracting
tar -xvmzk -f "$TAR_FILE" -C "$(dirname $TAR_FILE)" --include=$PRODUCT*_${SAT}_*.dat || exit $?
