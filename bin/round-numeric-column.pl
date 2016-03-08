#!/usr/bin/perl
# EM 22/10/11

use strict;
use warnings;
use Getopt::Std;

my $separator = "\t";

# rounds a column containing numeric values (e.g. for comparison)

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: round-numeric-column.pl <number of decimal digits> <col no>\n";
      print $fh "  rounds a column containing numeric values (e.g. for comparison)\n";
	print $fh "   input read from stdin, output written to stdout.\n";
}


# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "3 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 2);

my $nbDigits=shift;
my $colNo=shift;
$colNo--;

my $pattern="%.".$nbDigits."f";
while (<STDIN>) {
	chomp;
	my @columns = split;
	print join($separator, @columns[0 .. $colNo-1]).$separator if ($colNo>0);
	printf($pattern, $columns[$colNo]);
        print $separator.join($separator, @columns[$colNo+1 .. scalar(@columns)-1]) if ($colNo<scalar(@columns)-1);
	print "\n";
}
