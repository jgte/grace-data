#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$( cd $(dirname $0); pwd )
#constants: filename stuff
PREFIX=grace_1B

#default data characteristics
SAT='A'
VERSION=03
SOURCE=JPL

if [ $# -lt 1 ]
then
  echo "\
cat-l1b.sh [ <date> <product> [ <sat> [ <version> [ <source> ] ] ] | <dat file> ]

Either:
  - <date> in YYYYMM[DD]
  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TIM1B, TNK1B, USO1B, VSL1B
  Optional argument:
   - sat     : GRACE A or B, defaults to '$SAT' (irrelevant if <product> is 'KBR1B')
   - version : release versions, defaults to '$VERSION'
   - source  : data source institute, defaults to '$SOURCE'
  NOTICE:
   - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')

Or:
  - <dat file>, with complete path

NOTICE: v03 data is available in monthly files; all other versions are available in daily files"
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
    echo "ERROR:cat-l1b.sh: expecting date to be in YYYYMMDD format, with length equal to 8, not ${#DATE}."
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
      echo "ERROR:cat-l1b.sh: cannot understand product $2"
      exit 3;;
  esac
  [ $# -ge 3 ] && SAT="$3"
  [ $# -ge 4 ] && VERSION="$4"
  [ $# -ge 5 ] && SOURCE="$5"
  [ "$PRODUCT" == "KBR1B" ] && SAT="X"
  # building package filename
  if [ "$VERSION" == "03" ]
  then
    DAT_FILE=${PREFIX}_$YEAR-${MONTH}_$VERSION.dat
    DAT_PROD=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.dat
  else
    DAY=${DATE:6:2}
    DAT_FILE=${PREFIX}_$YEAR-${MONTH}-${DAY}_$VERSION.dat
    DAT_PROD=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.dat
  fi
  #define local coordinates
  LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/$YEAR

  #make sure tar file is extracted
  [ -e "$LOCALDIR/$DAT_FILE" ] || $DIR_NOW/extract-l1b.sh $@ 1>&2 || exit $?
fi
#double check
if [ ! -e "$LOCALDIR/$DAT_PROD" ]
then
  echo "ERROR:cat-l1b.sh: Cannot find file '$LOCALDIR/$DAT_PROD'."
  exit 3
fi

#show contents
$CONV -binfile $LOCALDIR/$DAT_PROD


