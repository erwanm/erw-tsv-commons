#!/usr/bin/perl



use strict;
use warnings;
use Getopt::Std;
use CLGTextTools::Stats qw/mean median stdDev geomMean harmoMean/;
use Carp;
use Math::CDF;
use Math::Trig;
use Data::Dumper;

my $progName="num-stats.pl";
my $NaN = "NA";
my $startAtCol=1;
my $stats="mean median stdDev";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: $progName [options] <tsv input file>\n";
	print $fh "\n";
	print $fh "  Reads the tsv input line by line; each line contains a series of numeric values;\n";
	print $fh "  for each line the following stats are printed: mean, median, std dev\n";
	print $fh "\n";
	print $fh "   Options:\n";
	print $fh "     -h print this help\n";
	print $fh "     -c <colNo> the series of values start at column colNo; prints the content\n";
	print $fh "        of the previous columns as it is (i.e. <col1> .. <colNo-1> <mean> ...)\n";
	print $fh "     -s <stats> print those stats instead of '$stats' (can contain geomMean, harmoMean)\n";
	print $fh "      and meanMinusStdDev\n";
	print $fh "\n";
}





# PARSING OPTIONS
my %opt;
getopts('hc:s:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "1 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 1);
$startAtCol=$opt{c} if (defined($opt{c}));
$startAtCol--;
$stats=$opt{s} if (defined($opt{s}));

my @stats = split(/\s+/, $stats);
#print STDERR "DEBUG stats= ".join(" ; ", @stats)."\n";

my $input = $ARGV[0];

open(FH, "<", $input) or die "$progName error: cannot open '$input'";
while (my $line = <FH>) {
    chomp($line);
    my @cols = split(/\t/, $line);
    my @prefix;
    for (my $i=0; $i<$startAtCol; $i++) {
	my $v = shift(@cols);
	push(@prefix,$v);
    }
    my $prefix = join("\t", @prefix);
    if ($prefix ne "") {
	print "$prefix\t";
    }
    my @vals;
    for (my $i=0; $i<scalar(@stats); $i++) {
	if ($stats[$i] eq "mean") {
	    push(@vals,  mean(\@cols, $NaN) );
	} elsif ($stats[$i] eq "median") {
	    push(@vals,  median(\@cols, $NaN) );
	} elsif ($stats[$i] eq "geomMean") {
	    push(@vals,  geomMean(\@cols, $NaN) );
	} elsif ($stats[$i] eq "stdDev") {
	    push(@vals,  stdDev(\@cols, $NaN) );
	} elsif ($stats[$i] eq "harmoMean") {
	    push(@vals,  harmoMean(\@cols, $NaN) );
	} elsif ($stats[$i] eq "meanMinusStdDev") {
	    push(@vals,  mean(\@cols, $NaN) - stdDev(\@cols, $NaN) );
	} else {
	    die "$progName: error, invalid stat id '".$stats[$i]."'";
	}
    }
    print join("\t", @vals)."\n";
    
}
close(FH);
