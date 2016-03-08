#!/usr/bin/perl

use strict;
use warnings;

my $sepa="\t";
my $NaN="NA";

# erwan 5/4/11
if (scalar(@ARGV) != 3) {
    print STDERR "arg1 = column to filter no, arg 2 = min value, arg 3 = max value\n";
    exit 1;
}
my $idCol=$ARGV[0];
$idCol--;
my $min=$ARGV[1];
my $max=$ARGV[2];
my $lineNo=1;
while (<STDIN>) {
    chomp;
    my $line = $_;
    my @columns = split($sepa, $line);
    my $val = $columns[$idCol];
    if ($val eq $NaN) {
	warn "Ignoring '$val' line $lineNo";
    } else {
	if (($val >= $min) && ($val <= $max)) {
	    print "$line\n";
	}
    }
    $lineNo++;
}
