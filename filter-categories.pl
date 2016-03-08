#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

my $separator = "\t";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: filter-categories.pl [-f] [-k] <column name> <prefix output> <suffix output>\n";
	print $fh "   input read from stdin, output written to N files '<prefix>n<suffix>'.\n";
	print $fh "   default column = last column. first line = header.\n";
	print $fh "   classifies lines according to their value in column name.\n";
	print $fh "   -k: keep category column (default: removed)\n";
	print $fh "   -f writes header to outputs\n";
}


my %opt;
getopts('hfk', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "3 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 3);
my $colName = shift;
my $prefix=shift;
my $suffix=shift;
my $keepCol=$opt{k}?1:0;
my $printHeader=$opt{f}?1:0;

my $colNo = -1;
my %output;
my $lineNo=1;
my @header =();
while (<STDIN>) {
    chomp;
    my @columns = split;
    if ($colNo == -1) { # first line = header
        $colNo=0;
	foreach my $title (@columns) {
#	    print STDERR "DEBUG $colNo: $title = $colName ?\n";
	    if ($columns[$colNo] eq $colName) {
#		print STDERR "OK!\n";
		last;
	    } else {
		$colNo++;
	    }
	}
	die "Error: no value '$colName' in the first line, abort." if ($colNo >= scalar(@columns));
	if ($printHeader) {
	    if ($keepCol) {
		@header = @columns;
	    } else {
		push(@header, @columns[0 .. $colNo -1]) if ($colNo>0);
		push(@header, @columns[$colNo +1 .. scalar(@columns)-1]) if ($colNo < scalar(@columns)-1);
	    }
	}
    } else { # regular line
	my $val = $columns[$colNo];
	die "Error: no column ".($colNo+1)." line $lineNo." if (!defined($val));
	if (!defined($output{$val})) {
	   my $fh;
	   my $filename = $prefix.scalar(keys %output).$suffix;
	   open($fh, ">:encoding(utf-8)", $filename) or die "can not create file '$filename'.";
	   if ($printHeader) {
	       print $fh join($separator, @header)."\n";
	   }
	   $output{$val} = $fh;
	}
	my $fh = $output{$val};
	my @data;
	if ($keepCol) {
	    @data = @columns;
	} else {
	    if ($colNo>0) {
		push(@data, @columns[0 .. $colNo -1]);
	    }
	    if ($colNo < scalar(@columns)-1) {
		push(@data, @columns[$colNo +1 .. scalar(@columns)-1]);
	    }
	}
	print $fh join($separator, @data)."\n";
    }
    $lineNo++;
}
foreach my $val (keys %output) {
    close($output{$val});
}
