#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

my $progName="quote-fields.pl";

sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: $progName [-h]\n";
    print $fh "\n";
    print $fh "  Reads a TSV file from STDIN and prints its content with every\n";
    print $fh "  field (column value) between quotes to STDOUT.\n";
    print $fh "\n";
}


# PARSING OPTIONS
my %opt;
getopts('h', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "0 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 0);


while (<STDIN>) {
    chomp;
    my @cols = split /\t/;
    my @out = map { (m/^".*"$/)?$_:"\"".$_."\"" } @cols;
    print join("\t", @out)."\n";
}
