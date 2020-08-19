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

REMOTEHOST=https://podaac-tools.jpl.nasa.gov
LOCALDIR=$DIR_NOW/L2/$SOURCE/RL$VERSION/
LOG=${0%.sh}.log

SECRETFILE=$DIR_NOW/secret.txt
if [ ! -e "$SECRETFILE" ]
then
  echo "ERROR: file $SECRETFILE missing: create this file with your PO.DAAC username and password, each in one single line."
  exit 3
fi
USERNAME=$(head -n1 $SECRETFILE)
PASSWORD=$(tail -n1 $SECRETFILE)

#uncomment this if you haven't downloaded GRACE data yet:

# REMOTEDIR=drive/files/allData/grace/L2/$SOURCE/RL$VERSION/
# wget \
#   --user=$USERNAME \
#   --password=$PASSWORD \
#   --recursive \
#   --timestamping \
#   --continue \
#   --no-parent \
#   --no-directories \
#   --accept "*.gz" \
#   --show-progress \
#   --verbose \
#   --directory-prefix=$LOCALDIR \
#   $REMOTEHOST/$REMOTEDIR

for y in 2019 2020
do
  REMOTEDIR=drive/files/allData/gracefo/L2/$SOURCE/RL$VERSION/$y
  wget \
    --user=$USERNAME \
    --password=$PASSWORD \
    --recursive \
    --timestamping \
    --continue \
    --no-parent \
    --no-directories \
    --accept "*.gz" \
    --show-progress \
    --verbose \
    --directory-prefix=$LOCALDIR \
    $REMOTEHOST/$REMOTEDIR
done

#extract contents
$ECHO $DIR_NOW/extract-l2.sh $@

exit

#outdated FTP method follows

LOCALDIR=$DIR_NOW/L2/$SOURCE/RL$VERSION/

#create sink directory
[ ! -d $LOCALDIR ] && $ECHO mkdir -p $LOCALDIR

LFTPARGS="--only-newer --no-empty-dirs --loop --parallel=4 --include-glob=$GLOB"
LFTPOPEN="user $USERNAME $PASSWORD; open $REMOTEHOST"

if [[ ! "${@//manual/}" == "$@" ]]
then
  $ECHO lftp -e "$LFTPOPEN"
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

