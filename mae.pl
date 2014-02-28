#!/usr/bin/perl
# EM Feb 2014

use strict;
use warnings;
use Getopt::Std;

my $separator = "\t";


sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: mae.pl [options] <file1[:col1]> <file2[:col2]\n";
	print $fh "  Given two tsv files file1 and file2, each containing numeric\n";
	print $fh "  columns col1 and col2 (respectively) and the same number of lines,\n";
	print $fh "  prints the Mean Absolute Error (MAE) between these two columns.\n";
	print $fh "  Uses column 1 if no column specified.\n";
	print $fh "  \n";
	print $fh "  options:\n";
	print $fh "    -h print this help message\n";
}


# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "2 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 2);

my $param1=shift;
my $param2=shift;
my ($file1, $col1) = ($param1 =~ m/:/) ? ($param1 =~ m/^(.*):(.*)$/) : ( $param1, 1);
my ($file2, $col2) = ($param2 =~ m/:/) ? ($param2 =~ m/^(.*):(.*)$/) : ( $param2, 1);
$col1--;
$col2--;

open(FILE1, "<", $file1) or die "can not open $file1";
open(FILE2, "<", $file2) or die "can not open $file2";
my @content1 = <FILE1>;
my @content2 = <FILE2>;
close(FILE1);
close(FILE2);
die "Error: number of lines differ in $file1 and $file2" if (scalar(@content1) != scalar(@content2));
my $sum=0;
my $lineNo=1;
for (my $i=0; $i < scalar(@content1); $i++) {
    my @cols = split(/$separator/, $content1[$i]);
    die "Error: only ".scalar(@cols)." columns line $lineNo in $file1" if (scalar(@cols)<=$col1);
    my $val1 = $cols[$col1];
    @cols = split(/$separator/, $content2[$i]);
    die "Error: only ".scalar(@cols)." columns line $lineNo in $file2" if (scalar(@cols)<=$col2);
    my $val2 = $cols[$col2];
    $sum += abs($val1-$val2);
    $lineNo++;
}
my $mae = $sum / scalar(@content1);
print "$mae\n";
