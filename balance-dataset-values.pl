#!/usr/bin/perl
# EM March 2014

use strict;
use warnings;
use Getopt::Std;

my $separator = "\t";
my $epsilon = 0.00000000000001; # not very clean, but should not be a problem here.

sub usage {
	my $fh = shift;
	$fh = *STDOUT if (!defined $fh);
	print $fh "Usage: balance-dataset-values.pl [options] <file[:col]> <size>\n";
	print $fh "  Reads a column of values in <file> (column <col>, default 1),\n";
	print $fh "  and balances this set of values, i.e. return a pseudo-uniform\n"
	print $fh "  (random) distribution using only these values. Since the set of\n";
	print $fh "  values is actually discrete, the approximation consists in\n";
	print $fh "  the closet value whenever needed.\n";
	print $fh "  The resulting distribution is returned as a sorted set of indexes,\n";
	print $fh "  i.e., instead of returning the values their line nos in the input\n";
	print $fh "  file is given. This is intended to make it easier to extract\n";
	print $fh "  instances corresponding to these values (identical values are\n";
	print $fh "  taken care of: if there are several possibilites for a value,\n";
	print $fh "  line/instance number is also picked randomly).\n";
	print $fh "  Output is printed to STDOUT.\n";
	print $fh "  \n";
	print $fh "  options:\n";
	print $fh "    -h print this help message\n";
	print $fh "    -i <min1:max1:weight1>[;<min2:max2:weight2>...]\n";
	print $fh "       weight sub-intervals using these weights; all the possible\n";
	print $fh "       sub-intervals must be specified, or the weight of non supplied\n";
	print $fh "       intervals will be 0 so that no value can be picked from it.\n";
	print $fh "       The default value is of course <min:max:1>, thus assigning\n";
	print $fh "       the same weight to the whole range of values.\n";
	print $fh "       Intervals are always interpreted as [min,max[ (i.e. max excluded).\n";
	print $fh "  \n";
}

sub readColFile {
    my ($filename, $colNo)  = @_;
    my $lineNo=1;
    my @res;
    open(FILE, "<", $filename) or die "can not open $filename";
    while (my $line = <FILE>) {
	chomp($line);
#	die "Error: empty line in $filename at line $lineNo" if (!length("line"));
	my @cols = split(/$separator/, $line);
	die "Error: only ".scalar(@cols)." columns line $lineNo in $filename" if (scalar(@cols)<=$colNo);
	push(@res, $cols[$colNo]);
	$lineNo++;
    }
    close(FILE);
    return \@res;
}


sub parseIntervalsStr {
    my $str=shift;
    my @mapRanges;
    my $maxRandom = 0;
    my @elements = split(";", $str);
    die "-i format error" if (scalar(@elements)==0);
    for (my $i=0;$i<scalar(@elements);$i++) {
	my ($min,$max,$weight) =  split(":", $elements[$i]);
	die "-i format error in '$elements[$i]'" if (!strlen($weight));
	$maxRandom += $weight;
	$mapRanges[0] = [ $maxRandom, $weight, $min, $max ];
    }
    return ($maxRandom, \@mapRanges);
}


sub randomValueFromWeightedInterval {
    my $maxRandom = shift;
    my $mapRanges = shift;
    my $v = rand($maxRandom);
    my $i=0;
    while (($i<scalar(@$mapRanges)) && ($v >= $mapRanges->[$i]->[0])) {
	$i++;
    }
    die "Bug or error in -i option: reached the end of the possible intervals with random value $v" if ($i>=scalar(@$mapRanges));
    # mapping interval, not the fastest way but more explicit (to some extent...)
    my $startRangeRandom = ($mapRanges->[$i]->[0]-$mapRanges->[$i]->[1]);
    # remark: $sizeRangeRandom = $weight 
    my $sizeRangeValues = $mapRanges->[$i]->[3]-$mapRanges->[$i]->[2];
    my $relativeV = $v - $startRangeRandom;
    my $targetValue = $relativeV * $sizeRangeValues / $weight;
    return $targetValue;
}


sub pickOne {
    my ($list) = @_;
    die "Error: empty list" if (scalar(@$list)==0);
    my $randomIndex = int(rand(scalar(@$list)));
    my $val = $list->[$randomIndex];
    return $val;
}


# not optimal (ranges)
sub structUniq {
    my $values = shift;
    my $sortedIndexes = shift;
    my %map;
    my @range;
    for (my $i=0;$i<scalar(@$values);$i++) {
	my $v = $values[$sortedIndexes[$i]];
	if (defined($map{$v})) {
	    push(@{$map{$v}}, $sortedIndexes[$i]);
	} else {
	    push(@range, $v);
	    $map{$v} = [ $sortedIndexes[$i] ] ;
	}
    }
    return (\@range, \%map);
}


# REALLY not optimal (use dichotomy)
sub findClosest {
    my $value = shift;
    my $uniqDiscreteRange = shift;
    my $i=0;
    while (($i<scalar(@$uniqDiscreteRange)) && ($value > $uniqDiscreteRange->[$i])) {
	$i++;
    }
    return $uniqDiscreteRange->[0] if ($i==0); # value <= uniq[0]
    return $uniqDiscreteRange->[$i-1] if ($i==scalar(@$uniqDiscreteRange)); # value > uniq[scalar(uniq)-1]
    if ($value - $uniqDiscreteRange->[$i-1]  > $uniqDiscreteRange->[$i] - $value) {
	return $uniqDiscreteRange->[$i];
    } else {
	return $uniqDiscreteRange->[$i-1]
    }
    
}



# PARSING OPTIONS
my %opt;
getopts('hi:', \%opt ) or  ( print STDERR "Error in options" &&  usage(*STDERR) && exit 1);
usage($STDOUT) && exit 0 if $opt{h};
print STDERR "2 arguments expected but ".scalar(@ARGV)." found: ".join(" ; ", @ARGV)  && usage(*STDERR) && exit 1 if (scalar(@ARGV) != 2);
my $intervalsStr=$op{i};
my $paramFile=shift;
my $size=shift;
my ($file, $col) = ($param =~ m/:/) ? ($param =~ m/^(.*):(.*)$/) : ( $param, 1);
$col--;

my $values = readColFile($file, $col);
my $nb=scalar(@$values)-1;
my @indexes = (0..$nb);
my @sortedIndexes = sort { $values->[$a] <=> $values->[$b] } @indexes;
my $minRange=$values->[$sortedIndexes[0]];
my $maxRange=$values->[$sortedIndexes[$nb-1]] + $epsilon;
$intervalsStr="$minRange:$maxRange:1" if (!defined($intervalsStr));
my ($randomMax, $mapWeights) = parseIntervalsStr($intervalsStr);
my ($uniqValues, $mapUniqValues) = structUniq($values, \@sortedIndexes);

my @res;
for (my $i=0;$i<$size;$i++) {
    my $value = randomValueFromWeightedInterval($maxRandom, $mapWeights);
    my $closest = findClosest($value, $uniqValues);
    my $index = pickOne($mapUniqValues->{$closest});
    push(@res, $index);
}

for my $index (sort { $a <=> $b } @res) { print "$index\n"; }
