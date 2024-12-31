#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

function help_string()
{
  echo "$0 <source> <version> [ <year> ] [ echo ] [ manual ]

Mandatory arguments:
- source  : CSR, GFZ or JPL (no other options possible), defaults to CSR

Optional arguments:
- version : as of 10/2018 (the 'RL' part is added internally), defaults to '$VERSION:
  - CSR   : 05, 05_mean_field, 06, 06.1
  - GFZ   : 05, 05_WEEKLY, 06
  - JPL   : 05, 05.1, 06
- year    : defines the year to download the data, can be multiple (must include the century, i.e. 20xy), defaults to 2023
- echo    : show what would have been done but don't actually do anything (optional)
- manual  : browse the remote data repository manually (optional)
- secret  : use secret file (legacy: not relevant for ISDC, which is the server currently in use, optional)
- help    : show this string (optional)
"
}

#inits
SOURCE=
VERSION=06.2
ECHO=
MANUAL=false
YEARS=()
SECRET=false
for i in "$@"
do
  case "$i" in
    -x)
      set -x
    ;;
    CSR|GFZ|JPL)
      SOURCE=$i
    ;;
    0[56]*)
      VERSION=$i
    ;;
    20*)
      YEARS+=($i)
    ;;
    echo)
      ECHO=echo
    ;;
    manual)
      MANUAL=true
      SECRET=true
    ;;
    secret)
      SECRET=true
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
if [ -z "$SOURCE" ]
then
  echo "ERROR: need <source>"
  help_string
  exit 3
fi

#patch missing year
if [ ${#YEARS[@]} -eq 0 ]
then
  YEARS+=(2024)
fi

# deprecated:
# REMOTEHOST=https://podaac-tools.jpl.nasa.gov
# REMOTEDIR_BASE=drive/files/allData/gracefo/L2

REMOTEHOST=ftp://isdcftp.gfz-potsdam.de

#define local coordinates
LOCALDIR=$DIR_NOW/L2/$SOURCE/RL$VERSION/
LOG=${0%.sh}.log

if $SECRET
then
  SECRETFILE=$DIR_NOW/secret.txt
  if [ ! -e "$SECRETFILE" ]
  then
    echo "ERROR: file $SECRETFILE missing: create this file with your ISDC username and password, each in one single line."
    exit 3
  fi
  USERNAME=$(head -n1 $SECRETFILE)
  PASSWORD=$(tail -n1 $SECRETFILE)
  SECRET_ARGS="--user=$USERNAME --password=$PASSWORD"
  SECRET_ARGS_MANUAL="user $USERNAME $PASSWORD;"
else
  SECRET_ARGS=
  SECRET_ARGS_MANUAL=
fi

if $MANUAL
then
  $ECHO lftp -e "$SECRET_ARGS_MANUAL open $REMOTEHOST; cd grace-fo/Level-2; ls"
  exit
fi

for y in ${YEARS[@]}
do
  #resolved GRACE/GRACE-FO
  if [ $y -le 2017 ]
  then
    REMOTEDIR_BASE=grace/Level-2
  else
    REMOTEDIR_BASE=grace-fo/Level-2
  fi

  REMOTEDIR=$REMOTEDIR_BASE/$SOURCE/RL$VERSION
  $ECHO wget \
    $SECRET_ARGS \
    --recursive \
    --timestamping \
    --continue \
    --no-parent \
    --no-directories \
    --accept "GSM-2_$y*.gz" \
    --show-progress \
    --verbose \
    --directory-prefix=$LOCALDIR \
    $REMOTEHOST/$REMOTEDIR
done

#extract contents
$ECHO $DIR_NOW/extract-l2.sh $SOURCE $VERSION
