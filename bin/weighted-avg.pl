#!/usr/bin/perl

# EM 17/02/13


use strict;
use warnings;
use Getopt::Std;




sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: weighted-avg.pl\n";
	print $fh "   reads on STDIN lines of the form <freq> <value> and prints the average\n";
	print $fh "   of the values (2nd col) weighted according to the first column.\n";
	print $fh "\n";
	print $fh "   Options:\n";
	print $fh "   -h this help msg\n";
	print $fh "\n";
}

# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "0 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if  (scalar(@ARGV) != 0);

my $sum=0;
my $nb=0;
my $lineNo=1;
while (<STDIN>) {
    chomp;
    my ($freq, $val) = split;
    die "Error: no frequency and/or value on line $lineNo" if (!defined($freq) || !defined($val));
    $nb += $freq;
    $sum += $val * $freq;
    $lineNo++,
}
my $avg = $sum / $nb;
print "$avg\n";
