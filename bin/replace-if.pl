#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

my $replaceValue="NULL";

sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: replace-if.pl [OPTIONS] <list filename> <column1 No> [ <column2 No> ... ]\n";
    print $fh "   input read from STDIN, output written to STDOUT.\n";
    print $fh "   for each line, replace the value in any of the supplied columns with \n";
    print $fh "   $replaceValue if it belongs to the  list of values read in <list filename>.\n";
    print $fh "OPTIONS:\n";
    print $fh "   -n opposite condition: replaces if the values does NOT belong to the list.\n";
    print $fh "   -v <value> use this replace value instead of $replaceValue.\n";
    print $fh "\n";
}


my %opt;
getopts('hnv:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "at least 2 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) < 2);
my $listFilename = shift;
my @colsNos = map { $_ - 1 } @ARGV;
$replaceValue = $opt{v} if (defined($opt{v}));
my $conditionIsMember = $opt{n}?0:1;

my %list;
open(LIST, "<:encoding(utf-8)", $listFilename) or die "Can not open $listFilename";
while (<LIST>) {
    chomp;
    $list{$_} = 1;
}
close(LIST);

my $lineNo=1;
while (<STDIN>) {
    chomp;
    my @cols = split /\t/;
    foreach my $colNo (@colsNos) {
	die "Error: not enough columns line $lineNo" if (!defined($cols[$colNo]));
	my $inList = defined($list{$cols[$colNo]});
	if (($inList && $conditionIsMember) || (!$inList && !$conditionIsMember)) {
	    $cols[$colNo] = $replaceValue;
	}
    }
    print join("\t", @cols)."\n";
    $lineNo++;
}
