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
REMOTEHOST=podaac-ftp.jpl.nasa.gov
REMOTEDIR=allData/grace/L2/$SOURCE/RL$VERSION/
USERNAME=anonymous
PSSWD_FILE=$(cd $(dirname $BASH_SOURCE); pwd)/email.txt
if [ ! -e "$PSSWD_FILE" ]
then
  echo "ERROR: file $PSSWD_FILE missing: create this file with your email in one single line."
  exit 3
else
  PSSWD=$(cat "$PSSWD_FILE")
fi
LOG=${0%.sh}.log

#create sink directory
[ ! -d $LOCALDIR ] && mkdir -p $LOCALDIR

LFTPARGS="--only-newer --no-empty-dirs --loop --parallel=4 --include-glob=$GLOB"
LFTPOPEN="set ftp:use-mdtm yes && open -u $USERNAME,$PSSWD ftp://$REMOTEHOST"

if [[ ! "${@//manual/}" == "$@" ]]
then
  lftp -e "$LFTPOPEN"
  exit
fi

if [[ ! "${@//echo/}" == "$@" ]]
then
  PREFIX=echo
else
  PREFIX=
fi

#mirror remote to local
LFTPCOM+="
mirror $LFTPARGS $REMOTEDIR $LOCALDIR --log $LOG"
#debug
[[ ! "${@//debug/}" == "$@" ]] && {
  LFTPCOM+=" --dry-run"
  LFTPCOM=${LFTPCOM/--loop/}
}

$PREFIX lftp -e "$LFTPOPEN" <<%
$LFTPCOM
%

[ -z "$PREFIX" ] || echo "$LFTPCOM"

#extract contents
$(cd $(dirname $BASH_SOURCE); pwd)/gunzip-l2.sh $@