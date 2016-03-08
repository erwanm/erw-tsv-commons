#!/usr/bin/perl

use strict;
use warnings;

my $emptyValue="\"\"";
my $lineNo=1;
while (<STDIN>) {
    chomp;
#    my @cols = split(",", $_);
    my @cols = m/"([^"]*)"/g;
    my @out = map {(length($_)==0)?$emptyValue:$_ }  @cols;
    print join("\t", @out)."\n";
    $lineNo++;
}
