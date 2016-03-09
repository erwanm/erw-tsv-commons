#!/usr/bin/perl



use strict;
use warnings;
use Getopt::Std;
use Carp;

my $progName="restrict-range.pl";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: $progName [options] <min> <max>\n";
	print $fh "\n";
	print $fh " reads numeric values (one by line), and if the value does not belong to [min,max] changes it to min or max (whichever the closest)\n";
	print $fh "\n";
	print $fh "\n";
	print $fh "   Options:\n";
	print $fh "     -h print this help\n";
	print $fh "\n";
}



# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "2 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 2);
my $min=$ARGV[0];
my $max=$ARGV[1];

while (<STDIN>) {
    chomp;
    if (($_>=$min) && ($_<=$max)) {
	print "$_\n";
    } else {
	if ($_<$min) {
	    print "$min\n";
	} else {
	    print "$max\n";
	}
    }
}

