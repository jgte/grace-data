#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

if [ $# -lt 2 ]
then
  echo "$0 <source> <version> [ echo ] [ manual ]
Need at least two input arguments:
- the <source> can be CSR, GFZ or JPL
- the <version> can be (the 'RL' part is added internally), as of 10/2018:
  - CSR: 05, 05_mean_field, 06
  - GFZ: 05, 05_WEEKLY, 06
  - JPL: 05, 05.1, 06"
  exit 3
fi

#data characteristics
SOURCE=$1
VERSION=$2
GLOB="GSM-2*"

case $SOURCE in
CSR)
  case $VERSION in
  06)
    #do nothing
  ;;
  *)
    GLOB+="_0060_*"
  ;;
  esac
;;
GFZ)
  #do nothing
;;
JPL)
  #do nothing
;;
*)
  echo "$0: ERROR: unknown source '$SOURCE'."
  exit 3
esac

if [[ ! "$@" == "${@/echo}" ]]
then
  ECHO=echo
else
  ECHO=
fi    

LOCALDIR=$DIR_NOW/L2/$SOURCE/RL$VERSION/
REMOTEHOST=podaac-ftp.jpl.nasa.gov
REMOTEDIR=allData/grace/L2/$SOURCE/RL$VERSION/
USERNAME=anonymous
PSSWD_FILE=$DIR_NOW/email.txt
if [ ! -e "$PSSWD_FILE" ]
then
  echo "ERROR: file $PSSWD_FILE missing: create this file with your email in one single line."
  exit 3
else
  PSSWD=$(cat "$PSSWD_FILE")
fi
LOG=${0%.sh}.log

#create sink directory
[ ! -d $LOCALDIR ] && $ECHO mkdir -p $LOCALDIR

LFTPARGS="--only-newer --no-empty-dirs --loop --parallel=4 --include-glob=$GLOB"
LFTPOPEN="set ftp:use-mdtm yes && open -u $USERNAME,$PSSWD ftp://$REMOTEHOST"

if [[ ! "${@//manual/}" == "$@" ]]
then
  $ECHO lftp -e "$LFTPOPEN/$REMOTEDIR"
  exit
fi

#mirror remote to local
LFTPCOM+="
mirror $LFTPARGS $REMOTEDIR $LOCALDIR --log $LOG"
#debug
[[ ! "${@//debug/}" == "$@" ]] && {
  LFTPCOM+=" --dry-run"
  LFTPCOM=${LFTPCOM/--loop/}
}

$ECHO lftp -e "$LFTPOPEN" <<%
$LFTPCOM
%

[ -z "$ECHO" ] || echo "$LFTPCOM"

#extract contents
$ECHO $DIR_NOW/extract-l2.sh $@
