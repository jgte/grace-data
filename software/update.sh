#!/bin/bash -ue

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

#update this as needed
VERSION="2010-03-31"
REMOTE_HOST=https://podaac-tools.jpl.nasa.gov
REMOTE_DIR="drive/files/allData/grace/sw"
FILE_ROOT="GraceReadSW_L1_"
FILE_EXT=".tar.gz"

#derived parameters
LOCAL_DIR=$(cd $(dirname $BASH_SOURCE); pwd)
CWD=$PWD
FILENAME=$FILE_ROOT$VERSION.tar.gz
REMOTE_FILE=$REMOTE_HOST/$REMOTE_DIR/$FILENAME
LOCAL_FILE=$LOCAL_DIR/$FILE_ROOT$VERSION$FILE_EXT
SW_DIR=$LOCAL_DIR/RELEASE_$VERSION

#need credentials
SECRETFILE=$DIR_NOW/../secret.txt
if [ ! -e "$SECRETFILE" ]
then
  echo "ERROR: file $SECRETFILE missing: create this file with your PO.DAAC username and password, each in one single line."
  exit 3
fi
USERNAME=$(head -n1 $SECRETFILE)
PASSWORD=$(tail -n1 $SECRETFILE)

#download (if not already)
[ ! -e $LOCAL_FILE ] && wget \
  --user=$USERNAME \
  --password=$PASSWORD \
  --no-directories \
  $REMOTE_FILE

[[ ! "${@/--clean/}" == "$@" ]] && rm -fvr $SW_DIR

#decompress package (if not already)
[ ! -d $SW_DIR ] && tar -x -C $LOCAL_DIR -f $LOCAL_FILE -v

#need to tweak the make files
for i in $(find $SW_DIR -name Makefile)
do
  if [ ! -z "$(grep '^CFLAGS = $' $i)" ] || [ ! -z "$(grep '^CFLAGS =$' $i)" ]
  then
    CFLAGS=$(echo "
      -Wno-return-type
      -Wno-pointer-sign
      -Wno-implicit-int
      -Wno-implicit-function-declaration
      -Wno-format
      -Wno-pointer-bool-conversion
      -Wno-comment
      -Wno-incompatible-pointer-types
    " |tr '\n' ' '|tr -s ' ')
    echo "Adding appropriate compiler flags to $i"
    sed "s/CFLAGS =/CFLAGS = ${CFLAGS}/" $i > $i.tmp
    mv -fv $i.tmp $i
  fi
done
#need to tweak some code
for i in gps1x2rnx.c Bin2AsciiLevel1.c
do
  i=$(find $SW_DIR -name $i)
  if [ ! -z "$(grep 'int8_t \*argv\[\]' $i)" ]
  then
    sed 's/int8_t \*argv\[\]/char *argv[]/' $i > $i.tmp
    mv -fv $i.tmp $i
  fi
done

#update the location of the header files
i=$(find $SW_DIR -name GRACEsyspath.h)
if [ ! -z "$(grep '/goa/local/grace/includes' $i)" ]
then
  sed "s:/goa/local/grace/includes:${SW_DIR}:" $i > $i.tmp
  mv -fv $i.tmp $i
fi

#compile the software
make -C $SW_DIR

#create links to this dir
ln -svf $(basename $SW_DIR)/*.e .