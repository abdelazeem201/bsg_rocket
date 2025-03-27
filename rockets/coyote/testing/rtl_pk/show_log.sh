#!/bin/sh

#==========================================================================
# Show the log file
#==========================================================================
# Clean the log file from all memory error messages to make it easier to
# read the output from benchmarks/programs
#
# By\ Khalid Al-Hawaj
# Date\ 8th Feb. 2017

# Default log filename
logFile=run.log

# If we have any arguments, the first one is the log file name!
if [ $# -gt 0 ]; then
  logFile=$1
fi

grep -Ev "^Error:" ${logFile} | grep -Ev "^X'ing matched read address" | grep -Ev "^[[:space:]]*Offending"  | grep -Ev "^.*Attempt to read and write same address" | grep -Ev "^.*started at [[:digit:]]+ps failed at [[:digit:]]+ps" | less
