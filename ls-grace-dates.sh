#!/bin/bash -ue

function printfd
{
  printf "%${1}.0f" "$2"
}

function help_string()
{
  echo "$0 <source> <version> [ echo ]

Mandatory arguments:
- source  : CSR, GFZ or JPL (no other options possible)

Optional arguments:
- version : as of 10/2018 (the 'RL' part is added internally), defaults to 06:
  - CSR   : 05, 05_mean_field, 06
  - GFZ   : 05, 05_WEEKLY, 06
  - JPL   : 05, 05.1, 06
- echo    : show what would have been done but don't actually do anything
- help    : show this string
"
}

DATE=$(which gdate || which date)

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


LOCALDIR=$(cd $(dirname $BASH_SOURCE); pwd)/L2/$SOURCE/RL$VERSION

#check if sink directory exists
if [ ! -d $LOCALDIR ]
then
  echo "ERROR: cannot find directory $LOCALDIR"
  exit 3
fi

GSM_FILES=$(ls -U1 $LOCALDIR/*BA01*.gsm | sort)

COUNT_GZ=$( ls -U1 $LOCALDIR/*BA01*.gz  | wc -l)
COUNT_GSM=$( echo "$GSM_FILES" | wc -l)

if [ $COUNT_GSM -ne $COUNT_GZ ]
then
  echo "ERROR: there are $COUNT_GZ gz files and $COUNT_GSM gsm files, these numbers need to be the same."
  exit 3
fi

echo "
# Meaning of columns:
# 1 - GRACE model name
# 2 - First data day
# 3 - Middle data day
# 4 - Last data day
# 5 - Number of data days
# 6 - Number of gap days, i.e., between last data day of previous model and first data day of current model
# 7 - Number of days between the middle data day from previous and current models
# 8 - Number of days between the middle data day and the closes 16th day of the calendar month
#                                            1           2          3          4  5   6   7   8"

stop_sec=$($DATE -d '2002-04-05' +%s)
previous_middle_sec=0
for i in $GSM_FILES
do
  start=$(grep -h time_coverage_start $i | awk -F[:T] '{print $2}')
  start_sec=$($DATE -d $start +%s)
  gap_days=$(printfd 3 $(echo "($start_sec - $stop_sec)/24/3600" | bc))
  stop=$( grep -h time_coverage_end   $i | awk -F[:T] '{print $2}')
  stop_sec=$($DATE -d $stop +%s)
  data_days=$(echo "($stop_sec - $start_sec)/24/3600" | bc)
  stop=$($DATE -d "$stop -1 day" +%Y-%m-%d )
  middle=$($DATE -d "$start +$((data_days/2)) day" +%Y-%m-%d )
  middle_sec=$($DATE -d $middle +%s)
  if [ $previous_middle_sec -gt 0 ]
  then
    delta_middle_days=$(printfd 3 $(echo "($middle_sec - $previous_middle_sec)/24/3600" | bc))
  else
    delta_middle_days=N/A
  fi
  previous_middle_sec=$middle_sec
  y=$($DATE -d $middle +%Y)
  m=$($DATE -d $middle +%m)
  middle_month_sec=$($DATE -d "$y-$m-16" +%s)
  middle_month_offset_days=$(printfd 3 $( echo "($middle_sec - $middle_month_sec)/24/3600" | bc ))
  echo "$(basename $i) $start $middle $stop $data_days $gap_days $delta_middle_days $middle_month_offset_days"
done