#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd )

function help_string()
{
  echo "\
cat-l1b.sh <date> <product> [ <sat> ] [ <version> ] [ <source> ] ]

Either:
  - <date> in YYYYMM[DD]
  - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TIM1B, TNK1B, USO1B, VSL1B
  Optional argument:
   - sat     : GRACE A or B or GRACE-FO C or D, defaults to '$SAT' (irrelevant if <product> is 'KBR1B')
   - version : release versions, defaults to '$VERSION'
   - source  : data source institute, defaults to '$SOURCE'
  NOTICE:
   - if <product> is KBR1B, the third input argument is ignored (effectively replaced with 'X')

Or:
  - <dat file>, with complete path

NOTICE: v03 data is available in monthly files; all other versions are available in daily files"
}


#default data characteristics
SOURCE='JPL'
SAT='A'
VERSION=03
DATE=
PRODUCT=
ECHO=
for i in "$@"
do
  case "$i" in
    -x)
      set -x
    ;;
    GFZ|JPL)
      SOURCE=$i
    ;;
    0[2-9]*)
      VERSION=$i
    ;;
    20*)
      DATE=$i
      if [ "${#DATE}" -ne 8 ]
      then
        echo "ERROR:cat-l1b.sh: expecting date to be in YYYYMMDD format, with length equal to 8, not ${#DATE}."
        exit 3
      fi
    ;;
    *1B)
      PRODUCT=$i
    ;;
    [ABDC])
      SAT=$i
    ;;
    echo)
      ECHO=echo
    ;;
    help|-help|--help|h|-h)
      help_string
      exit 1
    ;;
    *)
      echo "ERROR: cannot handle input argument '$i'"
      exit 3
    ;;
  esac
done

#sanity in mandatory inputs
if [ -z "$DATE" ]
then
  echo "ERROR: need <date>"
  help_string
  exit 3
fi
if [ -z "$PRODUCT" ]
then
  echo "ERROR: need <product>"
  help_string
  exit 3
fi

# parsing inputs
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
DAY=${DATE:6:2}

#resolve GRACE/GRACE-FO
if [ $YEAR -le 2017 ]
then
  if [ "$VERSION" == "04" ]
  then
    echo "WARNING: resetting VERSION to 03, because GRACE does not have later data versions"
    VERSION=03
  fi
else
  if [ "$VERSION" == "02" ] || [ "$VERSION" == "03" ]
  then
    echo "WARNING: resetting VERSION to 04, because GRACE-FO does not have earlier data versions"
    VERSION=04
  fi
fi

[ "$PRODUCT" == "KBR1B" ] && SAT="X"

# building package filename
case "$VERSION" in
"02")
  DAY=${DATE:6:2}
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.dat
;;
"03")
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.dat
;;
"04")
  DAY=${DATE:6:2}
  #need to translate sate
  [ "$SAT" == "A" ] && SAT=C
  [ "$SAT" == "B" ] && SAT=D
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.txt
;;
*)
  echo "ERROR: cannot handle VERSION with value '$VERSION'."
  exit 3
esac

#define local coordinates
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/$YEAR

#make sure tar file is extracted
[ -e "$LOCALDIR/$DAT_FILE" ] || "$DIR_NOW/extract-l1b.sh" $@ 1>&2 || exit $?

#double check
if [ ! -e "$LOCALDIR/$DAT_FILE" ]
then
  echo "ERROR:cat-l1b.sh: Cannot find file '$LOCALDIR/$DAT_FILE'."
  exit 3
fi

#show contents
if [ $YEAR -le 2017 ]
then
  # converter
  CONV=$DIR_NOW/software/RELEASE_2010-03-31/Bin2AsciiLevel1.e
  # need execute perms
  chmod u+x $CONV
  # use converter to look inside binary data
  $CONV -binfile "$LOCALDIR/$DAT_FILE"
else
  cat "$LOCALDIR/$DAT_FILE"
fi


