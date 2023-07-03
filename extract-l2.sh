#!/bin/bash -u

function help_string()
{
  echo "$0 <source> <version> [ echo ]

Mandatory arguments:
- source  : CSR, GFZ or JPL (no other options possible)

Optional arguments:
- version : as of 10/2018 (the 'RL' part is added internally):
  - CSR   : 05, 05_mean_field, 06
  - GFZ   : 05, 05_WEEKLY, 06
  - JPL   : 05, 05.1, 06
- echo    : show what would have been done but don't actually do anything (optional)
- help    : show this string (optional)
"
}

#inits
SOURCE=
VERSION=06
ECHO=

for i in "$@"
do
  case "$i" in
    CSR|GFZ|JPL)
      SOURCE=$i
    ;;
    0[56]*)
      VERSION=$i
    ;;
    echo)
      ECHO=echo
    ;;
    help|-help|--help|h|-h)
      help_string
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
#sanity in mandatory inputs
if [ -z "$VERSION" ]
then
  echo "ERROR: need <version>"
  help_string
  exit 3
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
    $ECHO gunzip -kfv $i && mv -v ${i%.gz} ${i%.gz}.gsm
  fi
done





