#!/bin/bash -u

if [ $# -lt 2 ]
then
  echo "$0: ERROR: need at least two input arguments:
$0 <source> <version>

As of 11/2015:

the source can be:
- CSR
- GFZ
- JPL

version can be (the 'RL' part is added internally):
- CSR: 04, 05, 05_mean_field
- GFZ: 04, 04_UNCON, 05, 05_WEEKLY
- JPL: 04.1, 05, 05.1
"
  exit 3
fi

#data characteristics
SOURCE=$1
VERSION=$2

if [ $# -lt 3 ]
then
  case $SOURCE in
  CSR)
    GLOB="GSM-2*_0060_*"
  ;;
  GFZ)
    GLOB="GSM-2*"
  ;;
  JPL)
    GLOB="GSM-2*"
  ;;
  *)
    echo "$0: ERROR: unknown source '$SOURCE'."
    exit 3
  esac
fi

LOCALDIR=$(cd $(dirname $BASH_SOURCE); pwd)/L2/$SOURCE/RL$VERSION/

#check if sink directory exists
if [ ! -d $LOCALDIR ]
then
  echo "ERROR: cannot find directory $LOCALDIR"
  exit 3
fi

for i in $(find $LOCALDIR -name \*.gz)
do
  if [ ! -e ${i%.gz}.gsm ]
  then
    gunzip -kfv $i && mv -v ${i%.gz} ${i%.gz}.gsm
  fi
done





