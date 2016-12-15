#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;


my $printfPattern="%s";

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: transpose.pl\n";
	print $fh "  reads from STDIN unless arg is provided, writes to STDOUT.\n";
	print $fh "  transposes the table: columns become rows and conversely.\n";
	print $fh "\n";
	print $fh " Options:\n";
	print $fh "  -f <printf format> printf format for  a value, \n";
	print $fh "     default='$printfPattern'.\n";
	print $fh "\n";
}





# PARSING OPTIONS
my %opt;
getopts('hf:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "0 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) > 0);
$printfPattern=$opt{f} if (defined($opt{f}));

my @table;
my $nbCols = undef;
my $lineNo = 1;
while (<STDIN>) {
    chomp;
#    print "DEBUG line=$lineNo; $_\n";
    my @cols=split;
    $nbCols = scalar(@cols) if (!defined($nbCols));
    if ($nbCols != scalar(@cols)) {
	print STDERR "Error: $nbCols columns expected but ".scalar(@cols)." columns found line $lineNo\n";
	exit(1);
    }
    push(@table, \@cols);
    $lineNo++;
}

for (my $i=0; $i<$nbCols; $i++) {
    printf($printfPattern, $table[0]->[$i]);
    for (my $j=1; $j<scalar(@table); $j++) {
	printf( "\t".$printfPattern, $table[$j]->[$i]);
    }
    print "\n";
}
