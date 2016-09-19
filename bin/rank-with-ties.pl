#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

my $separator="\t";
my $progName="rank-with-ties.pl";

sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: $progName [-hr] <value column no>\n";
    print $fh "\n";
    print $fh "  sorts the lines read from STDIN according to the value in\n";
    print $fh "  'value column', and writes the result to STDOUT with one \n";
    print $fh "  additional column containing the rank (taking ties into \n";
    print $fh "  account). By default starting from lowest values, except if\n";
    print $fh "  option '-r' is supplied.\n";
    print $fh "\n";
}


# PARSING OPTIONS
my %opt;
getopts('rh', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "1 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 1);

my $revOrder = defined($opt{r});
my ($valueCol) = @ARGV;
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

