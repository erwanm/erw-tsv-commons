#!/usr/bin/perl

use strict;
use warnings;

# erwan 20/1/13

if (scalar(@ARGV) != 3) {
    print STDERR "Usage: swap-lines-randomly.pl [-r] <M> <input start line> <input end line>\n";
    print STDERR "  reads N lines from STDIN starting at line no <start> and ending at\n";
    print STDERR "  line no <end> (inclusive, counting from 1), and randomly swaps M\n";
    print STDERR "  pairs of lines randomly before writing the result to STDOUT.\n";
    print STDERR "  -r: with replacement (default: no replacement).\n";
    exit 1;
}

my $replacement=0;
if ($ARGV[0] eq "-r") {
    $replacement = 1;
    shift @ARGV;
}
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
