#!/bin/bash

progName=$(basename "$BASH_SOURCE")

function usage {
  echo
  echo "Usage: $progName [-h]" 
  echo
  echo " Reads input from STDIN and writes them to STDOUT preceded"
  echo " by the line number."
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
if [ $# -ne 0 ]; then
    echo "Error: expecting 0 args." 1>&2
    printHelp=1
fi
if [ ! -z "$printHelp" ]; then
    usage 1>&2
    exit 1
fi


n=1
while read l; do
    echo -e "$n\t$l"
    n=$(( $n + 1 ))
done
