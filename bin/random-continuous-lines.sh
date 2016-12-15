#!/bin/bash

# EM Dec 16

source common-lib.sh
source file-lib.sh

progName=$(basename "$BASH_SOURCE")


function usage {
  echo
  echo "Usage: $progName [options] <N> <input file>"
  echo
  echo "  Randomly selects an extract of <N> contiguous lines from <input file>."
  echo "  The output is written to STDOUT."
  echo
  echo "  Options:"
  echo "    -h this help"
  echo
}




OPTIND=1
while getopts 'h' option ; do 
    case $option in
	"h" ) usage
 	      exit 0;;
	"?" ) 
	    echo "Error, unknow option." 1>&2
            printHelp=1;;
    esac
done
shift $(($OPTIND - 1))
if [ $# -ne 2 ]; then
    echo "Error: expecting 2 arg." 1>&2
    printHelp=1
fi
if [ ! -z "$printHelp" ]; then
    usage 1>&2
    exit 1
fi
nb="$1"
file="$2"

nbIn=$(cat "$file" | wc -l)
max=$(( $nbIn - $nb ))

if [ $max -gt 0 ]; then
    randomStart=$(( ( $RANDOM % ( $max + 1 ) ) + 1 ))
    cat "$file" | tail -n +$randomStart | head -n $nb
else 
    echo "Warning: cannot pick $nb random lines among $nbIn lines in file '$file', printing full content" 1>&2
    cat "$file"
fi
