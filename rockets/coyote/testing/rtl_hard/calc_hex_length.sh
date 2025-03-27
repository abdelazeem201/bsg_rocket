#!/bin/sh

#=========================================================================
# Find elf2hex minimum number of lines rounded to the next power-of-two
#=========================================================================
# By\ Khalid Al-Hawaj
# 29th of Jan 2017
#
# This scripts inspects the header of a file and calculates the number of
# lines {length} for a hex file given a pre-determined width

# If we don't have enough arguments, gracefully die!
if [ $# -lt 3 ]; then
  echo 0
  exit 0
fi

# Parse arguments
OBJDUMP_CMD=$1
FILE=$2
WIDTH=$3

# Constant Commands
CMD_GET_HEADER="${OBJDUMP_CMD} -h ${FILE}"
CMD_GET_SECTIONS="egrep '^\s*[0-9]+\s*.*'"
CMD_LOWER_2_UPPER="tr 'a-z' 'A-Z'"
CMD_GET_BOUNDRY_EQU="sed -e 's/^ *[[:digit:]]\+ \+\.[^ ]\+ \+\([^ ]\+\) \+[^ ]\+ \+\([^ ]\+\) \+.*\$/ibase=16; \1 + \2; ibase=A; /g'"
CMD_GET_MAX="awk '{ if (\$1 > s) s = \$1 } END { print s / ${WIDTH} }'"
CMD_GET_BOUNDRIES="${CMD_GET_HEADER} | ${CMD_GET_SECTIONS} | ${CMD_LOWER_2_UPPER} | ${CMD_GET_BOUNDRY_EQU} | bc | ${CMD_GET_MAX}"

total=`eval "${CMD_GET_BOUNDRIES}"`
length=`echo "pwr=((l(${total}) + l(2) - (l(2) / 1000)) / l(2)); scale=0; 2^(pwr / 1)" | bc -l`
echo ${length}
