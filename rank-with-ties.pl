#!/usr/bin/perl

use strict;
use warnings;

my $separator = "\t";

if (scalar(@ARGV) < 1) {
    print STDERR "Usage: rank-with-ties <value column no> [rev]\n";
    print STDERR "  sorts the lines read from STDIN according to the value in\n";
    print STDERR "  'value column', and writes the result to STDOUT with one \n";
    print STDERR "  additional column containing the rank (taking ties into \n";
    print STDERR "  account). By default starting from lowest values, except if\n";
    print STDERR "  option 'rev' is supplied.\n";
    exit 1;
}
my ($valueCol, $revOrder) = @ARGV;
$valueCol--;

my @lines;
my %valueByLine;

my $nb=0;
while (<STDIN>) {
	chomp;
	my @columns = split;
	my $line=$_;
#	print STDERR "DEBUG: $nb - $line\n";
	my $val = $columns[$valueCol];
#	if ($val !~ m/^\d*\.?\d*$/) { BAD: number can be X.XXXeYY
#	  print "ERROR $nb: '$val'";
#	  exit(2);
#	}
	if (!defined($val) ) {
		print STDERR "Error: no value found line ".($nb+1).".";
		exit(2);
	}
	$lines[$nb] = $line;
	$valueByLine{$nb} = $val;
	$nb++;
}

my @sorted;
if (defined($revOrder) && ($revOrder eq "rev")) {
  @sorted = sort {$valueByLine{$b} <=> $valueByLine{$a}} (keys %valueByLine);
} else {
  @sorted = sort {$valueByLine{$a} <=> $valueByLine{$b}} (keys %valueByLine);
}

# print "debug ".join(';',@sorted)."\n";
my $i=0;
while ($i < scalar(@sorted)) {
#    print "DEBUG - $lines[$sorted[$i]]\n";
	my $first = $i;
	my $nbTies=0;
	while (($i+1<scalar(@sorted)) && ($valueByLine{$sorted[$i]} == $valueByLine{$sorted[$i+1]})) {
		$nbTies++;
		$i++;
	}
	my $rank = ((2 * ($first+1)) + $nbTies) / 2;
	for (my $j = $first; $j<= $first+$nbTies; $j++) {
		print "$lines[$sorted[$j]]$separator$rank\n";
	} 
	$i++;
}

