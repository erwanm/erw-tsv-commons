#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use CLGTextTools::Commons qw/readTSVLinesAsArray/;
use CLGTextTools::Stats qw/averageByGroup/;
use Getopt::Std;
#use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($INFO);


my $progNamePrefix = "avg-by-group";
my $progname = "$progNamePrefix.pl";




sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "\n"; 
	print $fh "Usage: $progname [options] <value col no>\n";
	print $fh "  The input is read on STDIN. For every group of lines (see option -g), the\n";
	print $fh "  average value taken from column <value col no> is computed and printed to\n";
	print $fh "  STDOUT.\n";
	print $fh " WARNING: columns nos are indexed starting at 0 (first column is 0, 2nd is 1...)\n";
	print $fh "\n";
	print $fh "  Options:\n";
	print $fh "     -g <group id col nos> the columns nos by which series of data should be\n";
	print $fh "        grouped, separated by commas. For example \"2,4\" is provided then\n";
	print $fh "        all lines with identical values in columns 2 and 4 are grouped together,\n";
	print $fh "        and the result for each group is <val arg2> <val arg4> <average value>.\n";
	print $fh "        If no col no is provided (empty string), then the \"group\" is the whole\n";
	print $fh "        data and the global average is the only output. Default: 1 (first col).\n";
	print $fh "     -c check that there is the same number of values/lines in every group.\n";
	print $fh "     -e <expected number> same as -c + checks that the number of lines is this \n"; 
 	print $fh "        expected number.\n"; 
#	print $fh "     -d use only when ranks are averaged. divide the resulting average value by \n"; 
#	print $fh "        the number of segments by group, in order to obtain a final rank between\n"; 
#	print $fh "        1 and N where N is the number of elements.\n";
#	print $fh "     -n By default a warning is issued if NaN values are found. Use this option\n";
#	print $fh "        not to send these warnings.\n"; 
#	print $fh "     -o <filename> prints the output to this file instead of printing it.\n"; 
	print $fh "     -h print this help message\n"; 
	print $fh "\n"; 
}


# main
# PARSING OPTIONS
my %opt;
getopts('g:ce:h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage(*STDOUT) && exit 0 if $opt{h};
print STDERR "1 argument expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 1);
my $params;
$params->{valueArgNo} = shift;
$params->{groupByArgsNos} = $opt{g} if (defined($opt{g}));
$params->{checkSameNumberByGroup} = defined($opt{c})?1:0;
$params->{expectedNumberByGroup} = $opt{e} if (defined($opt{e}));

my $table = readTSVLinesAsArray(*STDIN);
averageByGroup($table, $params);
