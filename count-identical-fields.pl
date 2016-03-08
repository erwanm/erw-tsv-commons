#!/usr/bin/perl
# EM Aug 11

use strict;
use warnings;
use Getopt::Std;

my $separator = "\t";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: count-identical-fields.pl <col-1> [<col-2> ... <col-n>]\n";
	print $fh "       input=STDIN, output=STDOUT\n";
	print $fh "       lines of data are grouped together if and only if the value(s) in\n";
	print $fh "       col-1...col-n are identical. The output is of the form\n";
	print $fh "       <col-1> ... <col-n> <nb>\n";
	print $fh "       where nb is the number of lines having these values\n";
	print $fh "\n";
	print $fh "   -o <suffix>, if supplied, writes each line to a file named with the\n";
	print $fh "      target column values: <col-1>-...-<col-n>.<suffix>\n";
	print $fh "   -s single category: consider all the values from the different columns\n";
	print $fh "     as belonging to the same category (i.e. as if they were in the same\n";
	print $fh "     column). incompatible with -o.\n";
}

# PARSING OPTIONS
my %opt;
getopts('hso:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "at least 1 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) < 1);
my $writeToSuffix=$opt{o};
my $singleCateg=defined($opt{s})?1:0;
my @colsNo;
while (my $col = shift) {
	push(@colsNo,$col-1);
}

my %data;
my %files;
my $lineNo=1;
#print STDERR "DEBUG ".join(";",@colsNo)."\n";
while (<STDIN>) {
	chomp;
	my @columns = split;
#	for (my $i=0; $i<scalar(@columns); $i++) {
#	    print STDERR "$i=$columns[$i]\n";
#	}
	my @values = map { $columns[$_] } @colsNo;
#	for (my $i=0; $i<scalar(@values); $i++) {
#	    print STDERR "values $i=$values[$i]\n";
#	}
#	foreach my $v (@values) {
#	    print STDERR "$v\n";
#	    die "undefined value line $lineNo" if (!defined($v));
#	}
	if ($singleCateg) {
	    foreach my $val (@values) {
		$data{$val}++;
	    }
	} else {
	    my $valuesStr = join($separator, @values);
	    $data{$valuesStr}++;
	    if (defined($writeToSuffix)) {
		my $filePrefix = join("-", @values);
		my $fh;
		if (defined($files{$filePrefix})) {
		    $fh = $files{$filePrefix};
		} else {
		    open($fh,">:encoding(utf-8)", $filePrefix.".".$writeToSuffix) or die "Error creating file '$filePrefix.$writeToSuffix'";
		    $files{$filePrefix} = $fh;
		}
		print $fh join($separator, @columns)."\n";
	    }
	}
	$lineNo++;
}
foreach (keys %data) {
	print "$_$separator$data{$_}\n";
}
foreach (values %files) {
    close($_);
}
