#!/usr/bin/perl
use strict;
use warnings;

while (<STDIN>) {
    chomp;
    my @cols = split /\t/;
    my @out = map { (m/^".*"$/)?$_:"\"".$_."\"" } @cols;
    print join("\t", @out)."\n";
}
