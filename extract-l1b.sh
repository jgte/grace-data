#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

function help_string()
{
  echo "\
extract-l1b.sh <date> <product> [ <sat> ] [ <version> ] [ <source> ]

 - <date> in YYYYMM
 - <product> name: ACC1B, AHK1B, GNV1B, KBR1B, MAS1B, SCA1B, THR1B, CLK1B, GPS1B, IHK1B, MAG1B, TDP1B, TIM1B, TNK1B, USO1B, VSL1B

Optional inputs:
 - sat     : GRACE A or B or GRACE-FO C or D, defaults to '$SAT' (irrelevant if <product> is 'KBR1B')
 - version : release versions, defaults to '$VERSION'
 - source  : data source institute, defaults to '$SOURCE'

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
        echo "ERROR:extract-l1b.sh: expecting date to be in YYYYMMDD format, with length equal to 8, not ${#DATE}."
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
  TAR_FILE=grace_1B_$YEAR-${MONTH}-${DAY}_$VERSION.tar.gz
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.dat
  MSG="Extracting v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH-$DAY: $TAR_FILE"
;;
"03")
  TAR_FILE=grace_1B_$YEAR-${MONTH}_$VERSION.tar.gz
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.dat
  MSG="Extracting v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH: $TAR_FILE"
;;
"04")
  DAY=${DATE:6:2}
  #need to translate sate
  [ "$SAT" == "A" ] && SAT=C
  [ "$SAT" == "B" ] && SAT=D
  #TODO: implement LRI and ACX file types
  TAR_FILE=gracefo_1B_$YEAR-${MONTH}-${DAY}_RL$VERSION.ascii.noLRI.tgz
  DAT_FILE=${PRODUCT}_$YEAR-${MONTH}-${DAY}_${SAT}_$VERSION.txt
  MSG="Extracting v$VERSION $SOURCE L1B GRACE-FO data for $YEAR-$MONTH-$DAY: $TAR_FILE"
;;
*)
  echo "ERROR: cannot handle VERSION with value '$VERSION'."
  exit 3
esac

#define local coordinates
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/$YEAR

#make sure tar file is available
[ -e "$LOCALDIR/$TAR_FILE" ] || "$DIR_NOW/download-l1b.sh" $DATE $VERSION $SOURCE || exit $?
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
  function machine_is
  {
    OS=`uname -v`
    [[ ! "${OS//$1/}" == "$OS" ]] && return 0 || return 1
  }
   # extracting
  if machine_is Darwin
  then
    tar -xvmzk -f "$LOCALDIR/$TAR_FILE" -C "$LOCALDIR" --include=$DAT_FILE || exit $?
  else
  	if [ "$VERSION" == "03" ]
  	then
  		tar -xvmk -f "$LOCALDIR/$TAR_FILE" -C "$LOCALDIR" --wildcards --no-anchored $DAT_FILE || exit $?
  	else
  		tar -xvmzk -f "$LOCALDIR/$TAR_FILE" -C "$LOCALDIR" --wildcards --no-anchored $DAT_FILE || exit $?
  	fi
  fi
fi
