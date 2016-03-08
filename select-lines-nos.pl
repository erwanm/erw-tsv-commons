#!/usr/bin/perl
# EM 25/9/11 - update 16/2/12 (-n)

use strict;
use warnings;
use Getopt::Std;

my $separator = "\t";


sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: select-line-nos.pl [-i] [-n] [-f <no first line>] <line nos file> <line nos col>\n";
	print $fh "       filters the lines read from STDIN according to the line numbers provided\n";
	print $fh "       in column <line nos col> from file <line nos file>, and writes (only)\n";
	print $fh "       the selected lines to STDOUT.\n";
	print $fh "       the 'line nos' values must be sorted (in ascending order).\n";  
	print $fh "       By default standard line numbering is used (1=first line), but if -s <n>\n";
	print $fh "       is provided then <n> is considered as the line number for the first line.\n"; 
	print $fh "       -n does the opposite: only selects the lines which are NOT in the list of\n";
	print $fh "       line numbers.\n";
	print $fh "       -i: preprends each output line with its index (as read in <lines nos file>)\n" ;
	print $fh "\n";
	print $fh "       Remark: also works if the same line no is included several times (not with -n!).\n";
	print $fh "\n";
}

# PARSING OPTIONS
my %opt;
getopts('ihnf:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "2 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 2);
my $filename = shift;
my $colNo = shift;
$colNo--;
my $firstLineNo = defined($opt{f})?$opt{f}:1;
my $opposite = $opt{n}?1:0;
my $addIndex  = $opt{i}?1:0;

open(FILE, "<:utf8","$filename") or die "can not open $filename";
my $nb = 0;
my $currentLineNo = $firstLineNo;
#print STDERR "starting from $currentLineNo\n";
my $line =<STDIN>;
while (<FILE>) {
	chomp;
	my @columns = split;
	my $selectedLineNo = $columns[$colNo];
	if (!defined($selectedLineNo)) {
		die "Error: not enough columns in $filename ? column ".($colNo+1)." not found line ".($nb+1);
	}
#	print STDERR "DEBUG currentLineNo=$currentLineNo; selectedLineNo=$selectedLineNo\n";
	while (($currentLineNo<$selectedLineNo) && (defined($line))) { # skip lines until next selected
#	    print STDERR "DEBUG $currentLineNo = $line (select=$selectedLineNo)\n";
	    if ($opposite) {
#		print STDERR "DEBUG opposite=TRUE, printing\n";
		print $addIndex ? "$currentLineNo\t$line" : "$line";
	    }
	    $currentLineNo++;
	    $line=<STDIN>;
	} 
#	print STDERR "DEBUG FOUND $currentLineNo = $line (select=$selectedLineNo)\n";
	if (defined($line)) {
	    if (!$opposite) {
		print $addIndex ? "$currentLineNo\t$line" : "$line";
	    } else {
#		print STDERR "DEBUG: skipping line $currentLineNo\n";
		$currentLineNo++;
		$line=<STDIN>;
	    }
	} else {
		die "Error: no line after line ".($currentLineNo-1)." in STDIN, can not reach line $selectedLineNo";
	}
	$nb++;
}
close(FILE);
if ($opposite && defined($line)) { # print all remaining lines
    print $addIndex ? "$currentLineNo\t$line" : "$line";
    while (<STDIN>) {
	my $line = $_;
	print $addIndex ? "$currentLineNo\t$line" : "$line";
	$currentLineNo++;
    }
}
