#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $separator = "\t";

if (scalar(@ARGV) < 2) {
	print STDERR "Usage: filter-column.pl [-n] <criterion file> <criterion col> [input column]\n";
	print STDERR "       the main input data is read on STDIN. The output consists in rows from\n";
	print STDERR "       this input data where the 'input column' satisfies the criterion. The\n";
	print STDERR "       criterion is that data must belong to the column 'criterion col' from\n";
	print STDERR "       file 'criterion file'.\n";
	print STDERR "       If 'input column' is not provided then the whole line is considered, and\n";
	print STDERR "       the condition is 'contains' instead of 'is equal to'.\n";
	print STDERR "       If '-n' is supplied, then the opposite condition is used: lines which\n";
	print STDERR "       do not belong to the criterion file are output.\n";
	print STDERR "       Ouput written to STDOUT.\n";
    exit 1;
}
my $optNot=0;
if ($ARGV[0] eq "-n") {
    $optNot=1;
  shift @ARGV;
}
my ($filename, $critCol, $inputCol) = @ARGV;
$critCol--;
$inputCol-- if defined($inputCol);
my %criterion;

open(FILE, "<:encoding(utf-8)","$filename") or die "can not open $filename";
my $nb = 0;
while (<FILE>) {
	chomp;
	my @columns = split;
#	print STDERR "DEBUG: $columns[0]\n$columns[1]\n$columns[2]\n$columns[3]\n\n";
	my $data = $columns[$critCol];
	if (!defined($critCol)) {
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
	my @columns = split;
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
