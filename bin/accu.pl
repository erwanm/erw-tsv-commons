#!/usr/bin/perl

use strict;
use warnings;

if (scalar(@ARGV) == 0) {
    print STDERR "Usage: accu.pl [ <column no 1> <column no 2> ... ]\n";
    print STDERR "  reads from STDIN, writes to STDOUT.\n";
    print STDERR "  for every line read, returns the same columns but for every column no\n";
    print STDERR "  given as parameter, also add a column containing the cumulated sum.\n";
    exit 1
}

my @colsNo  = map { $_ - 1 } (@ARGV);
my @accus;
while (<STDIN>) {
    chomp;
    my @cols=split;
    foreach my $colNo (@colsNo) {
	$accus[$colNo] += $cols[$colNo];
	push(@cols, $accus[$colNo]);
    }
    print join("\t",@cols)."\n";
}
