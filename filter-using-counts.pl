#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

my $keepUnknownCombinations=1;


sub usage {
    my $fh = shift;
    $fh = *STDOUT if (!defined $fh);
    print $fh "Usage: [OPTIONS] <count file> <threshold> <columns (comma separated)>\n";
    print $fh "\n";
    print $fh "   Apply a filter to instances read from STDIN (as tsv) and prints the remaining instances\n";
    print $fh "   to STDOUT.\n";
    print $fh "   For each possible combination of values read from the specified columns, <count file>\n";
    print $fh "   can contain two lines '<col1> .. <colN> <true|false> <Frequency>' (one for 'true', the other\n";
    print $fh "   for 'false');  every instance for which the proportion 'Freq. true' / 'Freq false' is lower\n";
    print $fh "   than 'threshold' is discarded.\n";
    print $fh "\n";
    print $fh "Options:\n";
    print $fh "  -o <discarded filename>  filename where discarded instances are written (otherwise ignored).\n";
    print $fh "  -d  discard unseen combinations (instead of keeping them by default).\n";
    print $fh "\n";
}

my %opt;
getopts('hdo:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "3 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 3);
my $trainingValuesFilename=shift;
my $minPercentage = shift;
my $columnsNoString = shift;
my $outputDiscarded = $opt{o};
$keepUnknownCombinations=0 if (defined($opt{d}));
my @colsPOS = map { $_-1 } split(/,/, $columnsNoString);
my $nbVals=scalar(@colsPOS);

my %valuesByTrigramAndClass;
open(FILE, "<$trainingValuesFilename") or die "can not open $trainingValuesFilename";
while (<FILE>) {
    chomp;
    my @cols = split /\t/;
    my $trigram = join(" ",@cols[0..$nbVals-1]);
    my $class = $cols[$nbVals];
    my $value = $cols[$nbVals+1];
    die "Error: not enough columns in $trainingValuesFilename (should be ".($nbVals+2).")" if (!defined($value));
    $valuesByTrigramAndClass{$trigram}->{$class} = $value;
}
close(FILE);
my %percentages;
foreach my $trigram (keys %valuesByTrigramAndClass) {
    my $false = $valuesByTrigramAndClass{$trigram}->{"false"};
#    print STDERR "DEBUG: $trigram\n";
    if (defined($false) && ($false > 0)) {
	my $true = $valuesByTrigramAndClass{$trigram}->{"true"};
	$percentages{$trigram} =  defined($true)?( $true / $false * 100):0;
    } else {
	$percentages{$trigram} = 100;
    }
}

open(OUT, ">:encoding(utf-8)", $outputDiscarded) or die "can not create $outputDiscarded" if (defined($outputDiscarded));


while (<STDIN>) {
    chomp;
    my @cols = split /\t/;
    my $trigram = join(" ", map { $cols[$_] } @colsPOS);
    if (!defined($percentages{$trigram})) {
	warn "Warning: unknown combination of values '$trigram'" ;
	if ($keepUnknownCombinations) {
	    print join("\t", @cols)."\n";
	} elsif (defined($outputDiscarded)) {
	    print OUT join("\t", @cols)."\n";
	}    
    } else {
	if ($percentages{$trigram} >=$minPercentage) {
	    print join("\t", @cols)."\n";
	} elsif (defined($outputDiscarded)) {
	    print OUT join("\t", @cols)."\n";
	}    
    }
}
close(OUT) if (defined($outputDiscarded));
