#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use open qw(:std :utf8);

my $separator = "\t";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: filter-column.pl [-hn] <criterion file> <criterion col> [input column]\n";
	print $fh "       the main input data is read on STDIN. The output consists in rows from\n";
	print $fh "       this input data where the 'input column' satisfies the criterion. The\n";
	print $fh "       criterion is that data must belong to the column 'criterion col' from\n";
	print $fh "       file 'criterion file'.\n";
	print $fh "       If 'input column' is not provided then the whole line is considered, and\n";
	print $fh "       the condition is 'contains' instead of 'is equal to'.\n";
	print $fh "       If '-n' is supplied, then the opposite condition is used: lines which\n";
	print $fh "       do not belong to the criterion file are output.\n";
	print $fh "       Ouput written to STDOUT.\n";
	print $fh "\n";
}


# PARSING OPTIONS
my %opt;
getopts('hn', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "at least 2 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) < 2);

my $optNot=defined($opt{n});

my ($filename, $critCol, $inputCol) = @ARGV;
$critCol--;
$inputCol-- if defined($inputCol);
my %criterion;

open(FILE, "<:encoding(utf-8)","$filename") or die "can not open $filename";
my $nb = 0;
while (<FILE>) {
	chomp;
	my @columns = split('\t');
#	print STDERR "DEBUG: $columns[0]\n$columns[1]\n$columns[2]\n$columns[3]\n\n";
	my $data = $columns[$critCol];
	if (!defined($data)) {
	    print STDERR "Error line ".($nb+1)." in criterion file: not enough columns.\n";
	    exit(2); 
	}
	$criterion{$data} = 1;
	$nb++;
}
close(FILE);

while (<STDIN>) {
	chomp;
	my $line = $_;
	my @columns = split('\t');
        my $data;
	if (defined($inputCol)) {
  	    my $data = $columns[$inputCol];
  	    print "$line\n" if ($criterion{$data} && !$optNot);
  	    print "$line\n" if (!defined($criterion{$data}) && $optNot);
        } else {
            $data = $line;
	    if (!$optNot) {
		foreach my $key (keys %criterion) {
		    if (($line =~ m/$key/)) {
			print "$line\n";
			last;
		    }
		}
	    } else {
		my $in=0;
		foreach my $key (keys %criterion) {
		    if (($line =~ m/$key/)) {
			$in=1;
			last;
		    }
		}
		print "$line\n" if (!$in);
            }
        }
}
