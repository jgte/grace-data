#!/bin/bash -ue

DIR=$(cd $(dirname $BASH_SOURCE);pwd)

KEYS=(
CAT_L1B_HELP
EXTRACT_L1B_HELP
DOWNLOAD_L1B_HELP
DOWNLOAD_L2_HELP
EXTRACT_L2_HELP
)

TMP_DIR=${TMP:-$TMPDIR}
if [ -z "$TMP_DIR" ]
then
  echo "WARNING: cannot find temporary directory, expecting environment variables TMP or TMPDIR to be set. Defaulting to '$DIR'."
  TMP_DIR=$DIR
fi

README=$(cat $DIR/README-template.md)
for i in ${KEYS[@]}
do
  SCRIPT=$DIR/$(
    echo $i \
    | sed 's:_HELP::' \
    | sed 's:_:-:g' \
    | tr 'A-Z' 'a-z').sh
  if [ ! -e $SCRIPT ]
  then
    echo "ERROR: cannot find script $SCRIPT"
    exit 3
  fi
  HELP_STR=$($SCRIPT help || true)
  README=${README/$i/$HELP_STR}
done
echo "$README" > $DIR/README.md
