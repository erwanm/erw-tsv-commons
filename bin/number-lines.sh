#!/bin/bash

n=1
while read l; do
    echo -e "$n\t$l"
    n=$(( $n + 1 ))
done
