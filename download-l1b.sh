#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

function help_string()
{
  echo "$0 <date> [ <version> ] [ <source> ]

 - <date> in YYYYMM[DD]

Optional inputs:
 - version : release versions, defaults to '$VERSION'
 - source  : data source institute, no defaults to '$SOURCE'

 NOTICE: v03 data is available in monthly files; all other versions are available in daily files"
}

#default data characteristics
SOURCE='JPL'
VERSION=03
DATE=
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
        echo "ERROR:download-l1b.sh: expecting date to be in YYYYMMDD format, with length equal to 8, not ${#DATE}."
        exit 3
      fi
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

#TODO: implement download AOD1B data
if [ "$SOURCE" == "GFZ" ]
then
  echo "ERROR: not implemented"
  exit 3
fi

#parsing inputs
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}

#resolved GRACE/GRACE-FO
if [ $YEAR -le 2017 ]
then
  REMOTEDIR_SAT=grace/Level-1B
  if [ "$VERSION" == "04" ]
  then
    echo "WARNING: resetting VERSION to 03, because GRACE does not have later data versions"
    VERSION=03
  fi
else
  REMOTEDIR_SAT=grace-fo/Level-1B
  if [ "$VERSION" == "02" ] || [ "$VERSION" == "03" ]
  then
    echo "WARNING: resetting VERSION to 04, because GRACE-FO does not have earlier data versions"
    VERSION=04
  fi
fi

# deprecated:
# REMOTEHOST=https://podaac-tools.jpl.nasa.gov
# REMOTEDIR_BASE=/drive/files/allData

REMOTEHOST=ftp://isdcftp.gfz-potsdam.de
REMOTEDIR_BASE=

# building package filename
case "$VERSION" in
"02")
  DAY=${DATE:6:2}
  TAR_FILE=grace_1B_$YEAR-${MONTH}-${DAY}_$VERSION.tar.gz
  REMOTEDIR=$REMOTEDIR_BASE/$REMOTEDIR_SAT/$SOURCE/INSTRUMENT/RL$VERSION/$YEAR
  MSG="Downloading v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH-$DAY: $TAR_FILE"
;;
"03")
  TAR_FILE=grace_1B_$YEAR-${MONTH}_$VERSION.tar.gz
  REMOTEDIR=$REMOTEDIR_BASE/$REMOTEDIR_SAT/$SOURCE/INSTRUMENT/RL$VERSION
  MSG="Downloading v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH: $TAR_FILE"
;;
"04")
  DAY=${DATE:6:2}
  #TODO: implement LRI and ACX file types
  TAR_FILE=gracefo_1B_$YEAR-${MONTH}-${DAY}_RL$VERSION.ascii.noLRI.tgz
  REMOTEDIR=$REMOTEDIR_BASE/$REMOTEDIR_SAT/$SOURCE/INSTRUMENT/RL$VERSION/$YEAR
  MSG="Downloading v$VERSION $SOURCE L1B GRACE-FO data for $YEAR-$MONTH-$DAY: $TAR_FILE"
;;
*)
  echo "ERROR: cannot handle VERSION with value '$VERSION'."
  exit 3
esac


#define local coordinates
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/$YEAR
LOG=${0%.sh}.log

#don't download unless necessary
if [ -e "$LOCALDIR/$TAR_FILE" ]
then
  echo "File $TAR_FILE already downloaded"
  exit
fi

#fetch the data
mkdir -p "$LOCALDIR" || exit $?
# wget  --directory-prefix="$LOCALDIR" $REMOTEHOST/$REMOTEDIR/$TAR_FILE
lftp -e "get -O $LOCALDIR /$REMOTEDIR/$TAR_FILE; exit" $REMOTEHOST
