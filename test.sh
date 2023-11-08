#!/bin/bash -ue

# keeping track of where I am
DIR=$(cd $(dirname $BASH_SOURCE); pwd)

$DIR/download-l1b.sh 20080808 02
$DIR/download-l1b.sh 20080808 03
$DIR/download-l1b.sh 20180808 04

$DIR/download-l1b.sh 20080809
$DIR/download-l1b.sh 20180809

$DIR/extract-l1b.sh 20080808 02 ACC1B
$DIR/extract-l1b.sh 20080808 03 KBR1B
$DIR/extract-l1b.sh 20180808 04 GNV1B

$DIR/extract-l1b.sh 20080809 KBR1B
$DIR/extract-l1b.sh 20180809 GNV1B

printf "\e[34mshowing data for 20080808 02 ACC1B\e[0m\n"
$DIR/cat-l1b.sh 20080808 02 ACC1B | tail
printf "\e[34mshowing data for 20080808 03 KBR1B\e[0m\n"
$DIR/cat-l1b.sh 20080808 03 KBR1B | tail
printf "\e[34mshowing data for 20180808 04 GNV1B\e[0m\n"
$DIR/cat-l1b.sh 20180808 04 GNV1B | tail

printf "\e[34mshowing data for 20080809 KBR1B\e[0m\n"
$DIR/cat-l1b.sh 20080809 KBR1B | tail
printf "\e[34mshowing data for 20080809 KBR1B\e[0m\n"
$DIR/cat-l1b.sh 20180809 GNV1B | tail
