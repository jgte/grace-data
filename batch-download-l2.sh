#!/bin/bash -u

# keeping track of where I am
DIR_NOW=$(cd $(dirname $BASH_SOURCE); pwd)

YEAR_LIST=$(seq 2009 2016)
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