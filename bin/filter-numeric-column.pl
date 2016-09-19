#!/usr/bin/perl

# erwan 5/4/11, update sept 16

use strict;
use warnings;
use Getopt::Std;

my $sepa="\t";
my $NaN="NA";
my $progName="filter-numeric-columns.pl";

sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: $progName [-h] <column no to filter> <min value> <max value>\n";
    print $fh "\n";
}


# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "3 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 3);

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
