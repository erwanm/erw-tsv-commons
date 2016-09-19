#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

my $progName="quoted-csv-to-tsv.pl";

sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: $progName [-h]\n";
    print $fh "\n";
}


# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "0 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 0);

my $emptyValue="\"\"";
my $lineNo=1;
while (<STDIN>) {
    chomp;
#    my @cols = split(",", $_);
    my @cols = m/"([^"]*)"/g;
    my @out = map {(length($_)==0)?$emptyValue:$_ }  @cols;
    print join("\t", @out)."\n";
    $lineNo++;
}
