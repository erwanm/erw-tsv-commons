#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;


my $printfPattern="%s";
my $progName="random-contiguous-chars.pl";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: $progName [options] <N>\n";
	print $fh "\n";
	print $fh "  Selects a sample of <N> contiguous chars from STDIN and\n";
	print $fh "  writes it to STDOUT.\n";
	print $fh "\n";
	print $fh " Options:\n";
	print $fh "  -l cut only on lines (results in approximating the number of chars)\n";
	print $fh "  -w cut only on words (results in approximating the number of chars)\n";
	print $fh "     Line breaks are removed with this option.\n";
	print $fh "  -n add new line at the end\n";
	print $fh "\n";
}





# PARSING OPTIONS
my %opt;
getopts('hlwn', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "1 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 1);

my $nb = $ARGV[0];

my $onlyCutLines=$opt{l};
my $onlyCutWords=$opt{w};
my $newLine=$opt{n};

my @units;

my $total = 0;

while (<STDIN>) {
    $total += length($_);
    if ($onlyCutWords) {
	my @words = split;
	my @wordsSpace = map { " ".$_ } @words;
	push(@units, @wordsSpace);
    } elsif ($onlyCutLines) {
	push(@units, $_);
    } else {
	my @chars = split("", $_);
	push(@units, @chars);
    }
}

if ($total <= $nb) {
    print STDERR "$progName: Warning: cannot sample $nb chars out of $total, printing full content.\n";
    foreach my $x (@units) {
	print "$x";
    }
} else {
    my $start = int(rand($total - $nb));
    my $stop = $start + $nb;
    my $stage = 0;
    my $pos = 0;
    for (my $i=0; ($stage <2) &&  ($i<scalar(@units)); $i++) {
	my $x = $units[$i];
	my $l = length($x);
	if ($pos+ $l > $start) {
	    if ($stage == 0) {
		# print current?
		my $end = $pos + $l;
		if ($start - $pos < $end - $start) { # expected start closer to beginning
		    print $x;
		}
		$stage = 1; # printing from now on
	    } elsif ($stage == 1) {
		if ($pos+$l > $stop) {
		    my $end = $pos + $l;
		    # print current?
		    if ($stop - $pos > $end - $stop) { # expected stop closer to end
			print $x;
		    }
		    $stage = 2;# finished
		} else {
		    print $x;
		}
	    }
	}
	
	$pos += $l;
    }
    print "\n" if ($newLine);
    
}
