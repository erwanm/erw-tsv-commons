#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;


sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: accu.pl [ <column no 1> <column no 2> ... ]\n";
	print $fh "  reads from STDIN, writes to STDOUT.\n";
	print $fh "  for every line read, returns the same columns but for every column no\n";
	print $fh "  given as parameter, also add a column containing the cumulated sum.\n";
	print $fh "\n";
}





# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "at least 1 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) < 1);

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
