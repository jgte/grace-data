#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)
#constants: filename stuff
PREFIX=grace_1B

#default data characteristics
VERSION=03
SOURCE=JPL

if [ $# -lt 1 ]
then
  echo "\
$0 <date> [ <version> [ <source> ] ]

 - <date> in YYYYMM[DD]

Optional inputs:
 - version : release versions, defaults to '$VERSION'
 - source  : data source institute, defaults to '$SOURCE'

 NOTICE: v03 data is available in monthly files; all other versions are available in daily files"
  exit 1
fi

#parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
[ $# -ge 2 ] && VERSION="$2"
[ $# -ge 3 ] && SOURCE="$3"
# building package filename
if [ "$VERSION" == "03" ]
then
  TAR_FILE=${PREFIX}_$YEAR-${MONTH}_$VERSION.tgz
  REMOTEDIR=drive/files/allData/grace/L1B/$SOURCE/RL$VERSION/
  MSG="Downloading v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH: $TAR_FILE"
else
  DAY=${DATE:6:2}
  TAR_FILE=${PREFIX}_$YEAR-${MONTH}-${DAY}_$VERSION.tar.gz
  REMOTEDIR=drive/files/allData/grace/L1B/$SOURCE/RL$VERSION/$YEAR
  MSG="Downloading v$VERSION $SOURCE L1B GRACE data for $YEAR-$MONTH-$DAY: $TAR_FILE"
fi
#define local and remote coordinates
REMOTEHOST=https://podaac-tools.jpl.nasa.gov
LOCALDIR=$DIR_NOW/L1B/$SOURCE/RL$VERSION/$YEAR
LOG=${0%.sh}.log

#don't download unless necessary
if [ -e "$LOCALDIR/$TAR_FILE" ]
then
  echo "File $TAR_FILE already downloaded"
  exit
fi

#retrieve password
SECRETFILE=$DIR_NOW/secret.txt
if [ ! -e "$SECRETFILE" ]
then
  echo "ERROR:download-l1b.sh: file $SECRETFILE missing: create this file with your PO.DAAC username and password, each in one single line."
  exit 3
fi
USERNAME=$(head -n1 $SECRETFILE)
PASSWORD=$(tail -n1 $SECRETFILE)

echo "$MSG"

#fetch the data
mkdir -p $LOCALDIR || exit $?
wget \
  --user=$USERNAME \
  --password=$PASSWORD \
  --recursive \
  --timestamping \
  --continue \
  --no-parent \
  --no-directories \
  --accept "$TAR_FILE" \
  --show-progress \
  --verbose \
  --directory-prefix=$LOCALDIR \
  $REMOTEHOST/$REMOTEDIR