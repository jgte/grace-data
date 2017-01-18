#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$( cd $(dirname $0); pwd )

if [ $# -lt 1 ]
then
  echo "$0 <date>"
  echo "Need at one input argument: <date> in YYYYMMDD"
  exit 1
fi

#data characteristics
VERSION=02
SOURCE=JPL

#parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
DAY=${DATE:6:2}

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

DIR_HERE=$DIR_NOW/L1B/$YEAR/$MONTH/$DAY
DIR_THERE=$YEAR
mkdir -p $DIR_HERE
wget $WGET_FLAGS -P $DIR_HERE --exclude-directories=$FTP_DIR/$DIR_THERE/.snapshot ${FTP_SITE}/$FTP_DIR/$DIR_THERE/$TAR_FILE


