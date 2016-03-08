#!/usr/bin/perl
# EM July 2014

use strict;
use warnings;
use Getopt::Std;


my $separator = "\t";
my $progName = "extract-lines.pl";
my $firstLineNo = 1;

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: $progName [options] <line nos file[:col]>\n";
	print $fh "  \n";
	print $fh "  filters the lines read from STDIN according to the line numbers provided\n";
	print $fh "  in file <line nos file>, and writes (only) the selected lines to STDOUT.\n";
	print $fh "  \n";
	print $fh "  Warning: this script stores the input in memory, so that it is possible:\n";
	print $fh "    - to select lines in any ordering (e.g. 3,7,5,2);\n";
	print $fh "    - to select the same line multiple times (e.g. 3,7,3,5,5,3);\n";
	print $fh "  However this limits the size of the input, which must not be higher than\n";
	print $fh "  the available memory.\n";
	print $fh "  \n";
	print $fh "  Options:\n";
	print $fh "  -f <n> use <n> as the line number for the first line (e.g. 0 if lines are\n";
	print $fh "         numbered from 0 to N-1).\n";
	print $fh "  -i preprends each output line with its index (as read in <lines nos file>)\n";
	print $fh "  \n";
}

sub readColFile {
    my ($filename, $colNo)  = @_;
    my $lineNo=1;
    my @res;
    open(FILE, "<", $filename) or die "can not open $filename";
    while (my $line = <FILE>) {
	chomp($line);
#	die "Error: empty line in $filename at line $lineNo" if (!length("line"));
	my @cols = split(/$separator/, $line);
	die "Error: only ".scalar(@cols)." columns line $lineNo in $filename" if (scalar(@cols)<=$colNo);
	push(@res, $cols[$colNo]);
	$lineNo++;
    }
    close(FILE);
    return \@res;
}




# PARSING OPTIONS
my %opt;
getopts('hf:i', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "1 argument expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 1);
$firstLineNo = $opt{f} if (defined($opt{f}));
my $indexOutput = $opt{i};
my $paramFile=shift;
my ($file, $colNo) = ($paramFile =~ m/:/) ? ($paramFile =~ m/^(.*):(.*)$/) : ( $paramFile, 1);
$colNo--;
die "$progName error: cannot find file '$file'." if (! -e "$file");

my @input = <STDIN>;
my $lineNoInputLinesNoFile=1;
open(LINESNO, "<", $file) or die "$progName error: cannot open '$file'.";
while (my $line = <LINESNO>) {
    chomp($line);
    die "$progName error: empty line in '$file' at line $lineNoInputLinesNoFile." if (!length($line));
    my @cols = split(/$separator/, $line);
    die "$progName error: only ".scalar(@cols)." columns line $lineNoInputLinesNoFile in '$file'." if (scalar(@cols)<=$colNo);
    my $lineNo = $cols[$colNo];
    die "$progName error: no line $lineNo in input, whcih contains only ".scalar(@input)." lines." if (scalar(@input)<=$lineNo-$firstLineNo);
    if (defined($indexOutput)) {
	print $lineNo.$separator;
    }
    print $input[$lineNo-$firstLineNo];
    $lineNoInputLinesNoFile++;
}
close(LINESNO);
