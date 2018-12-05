#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

if [ $# -lt 1 ]
then
  echo "ERROR: need list of 4-digit years"
  exit 3
fi

YEAR_LIST=$@
MONTH_LIST=$(seq -w 1 12)
DAY_LIST=$(seq -w 1 31)

for year in $YEAR_LIST
do
  for month in $MONTH_LIST
  do
    for day in $DAY_LIST
    do
      $DIR_NOW/download-l1b.sh $year$month$day
    done
  done
done