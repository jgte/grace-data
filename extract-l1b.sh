#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

if [ $# -lt 1 ]
then
  echo "Need at one input argument: <date> in YYYYMMDD"
  exit 1
fi

# parsing inputs
DATE=$1
YEAR=${DATE:0:4}
MONTH=${DATE:4:2}
DAY=${DATE:6:2}

#filename stuff
PREFIX=grace_1B
SUFFIX=.tar.gz

# building package filename and pick the most recent version
TAR_FILE=$(ls $DIR_NOW/L1B/$YEAR/$MONTH/$DAY/${PREFIX}_$YEAR-$MONTH-${DAY}_*$SUFFIX | tail -n1)

if [ ! -e "$TAR_FILE" ]
then
  echo "Cannot find file '$TAR_FILE'."
  exit 3
fi

# extracting
DIR_HERE=$(dirname $TAR_FILE)
mkdir -p $DIR_HERE
tar -xvmzk -f "$TAR_FILE" -C "$DIR_HERE" \
--exclude=CLK1B* \
--exclude=GPS1B* \
--exclude=IHK1B* \
--exclude=MAG1B* \
--exclude=MAS1B* \
--exclude=TDP1B* \
--exclude=TIM1B* \
--exclude=TNK1B* \
--exclude=USO1B* \
--exclude=VSL1B*
