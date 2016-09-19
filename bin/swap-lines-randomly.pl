#!/usr/bin/perl

# erwan 20/1/13, updated usage sept 16

use strict;
use warnings;
use Getopt::Std;

my $progName="swap-lines-randomly.pl";

sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: $progName [-hr] <M> <input start line> <input end line>\n";
    print $fh "\n";
    print $fh "  reads N lines from STDIN starting at line no <start> and ending at\n";
    print $fh "  line no <end> (inclusive, counting from 1), and randomly swaps M\n";
    print $fh "  pairs of lines randomly before writing the result to STDOUT.\n";
    print $fh "\n";
    print $fh "  -r: with replacement (default: no replacement).\n";
    print $fh "\n";
}


# PARSING OPTIONS
my %opt;
getopts('hr', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "3 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 3);



my $replacement=defined($opt{r});

my $nbSwaps = $ARGV[0];
my $min=$ARGV[1];
my $max=$ARGV[2];

die "Error: max-min+1 < 2*nboutput but option replacement is set." if ($replacement != 0) && ($max-$min+1<$nbSwaps*2);
my @input = <STDIN>;
unshift(@input, "DUMMY");
my @available = ($min..$max);
for (my $i=0; $i<$nbSwaps; $i++) {
    my $randomIndex1=-1;
    my $randomIndex2=-1;
    while ($randomIndex1==$randomIndex2) {
	die "Error (bug??): not enough available lines left" if (scalar(@available)<2);
	$randomIndex1 = int(rand(scalar(@available)));
	$randomIndex2 = int(rand(scalar(@available)));
    }
 #   print STDERR "available=".join(";", @available)." ; selected=$randomIndex1, $randomIndex2 -> $available[$randomIndex1], $available[$randomIndex2] \n";
    my $buffer = $input[$available[$randomIndex1]];
    $input[$available[$randomIndex1]] = $input[$available[$randomIndex2]];
    $input[$available[$randomIndex2]] = $buffer;
    if ($replacement == 0) {
	$available[$randomIndex1] = $available[0];
	shift @available;
#	print STDERR "DEBUG1 available=".join(";", @available)."\n";
	if ($randomIndex2>0) {
	    $available[$randomIndex2-1] = $available[0];
	}
	shift @available;
#	print STDERR "DEBUG2 available=".join(";", @available)."\n";
    }
}


for (my $i=$min; $i<=$max; $i++) {
    print $input[$i];
}
