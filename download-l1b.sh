#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

#default data characteristics
VERSION=02
SOURCE=JPL

if [ $# -lt 1 ]
then
  echo "$0 <date> [ <version> [ <source> ] ]"
  echo
  echo "Optional inputs:"
  echo " - version : release versions, defaults to '$VERSION'"
  echo " - source  : data source institute, defaults to '$SOURCE'"
  exit 1
fi

#parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
DAY=${DATE:6:2}

[ $# -ge 2 ] && VERSION="$2"
[ $# -ge 3 ] && SOURCE="$3"

REMOTEHOST=https://podaac-tools.jpl.nasa.gov
REMOTEDIR=drive/files/allData/grace/L1B/$SOURCE/RL$VERSION/$YEAR
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/
LOG=${0%.sh}.log

SECRETFILE=$DIR_NOW/secret.txt
if [ ! -e "$SECRETFILE" ]
then
  echo "ERROR: file $SECRETFILE missing: create this file with your PO.DAAC username and password, each in one single line."
  exit 3
fi
USERNAME=$(head -n1 $SECRETFILE)
PASSWORD=$(tail -n1 $SECRETFILE)

mkdir -p $LOCALDIR || exit $?
wget \
  --user=$USERNAME \
  --password=$PASSWORD \
  --recursive \
  --timestamping \
  --continue \
  --no-parent \
  --no-directories \
  --accept "*$YEAR-$MONTH-$DAY*.gz" \
  --show-progress \
  --verbose \
  --directory-prefix=$LOCALDIR \
  $REMOTEHOST/$REMOTEDIR

exit

#outdated FTP method follows

#where to download stuff
FTP_SITE=ftp://podaac-ftp.jpl.nasa.gov
FTP_DIR=allData/grace/L1B/$SOURCE/RL$VERSION/

#filename stuff
PREFIX=grace_1B
SUFFIX=.tar.gz

# building package filename
TAR_FILE=${PREFIX}_$YEAR-$MONTH-${DAY}_$VERSION$SUFFIX

# continue, no host dir, cut 3 dirs, mirror (recursive, timestamp, infinite depth, keep listings), no parent
WGET_FLAGS="-c -nH --cut-dirs=7 -m -np"

DIR_HERE=$DIR_NOW/L1B/$YEAR
DIR_THERE=$YEAR
mkdir -p $DIR_HERE || exit $?

# checking if data was already downloaded
[ ! -e "$DIR_HERE/$TAR_FILE" ] && wget $WGET_FLAGS -P $DIR_HERE --exclude-directories=$FTP_DIR/$DIR_THERE/.snapshot ${FTP_SITE}/$FTP_DIR/$DIR_THERE/$TAR_FILE

