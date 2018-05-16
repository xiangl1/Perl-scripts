#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use autodie;

my ($infile, $outfile) = @ARGV;
open my $in_fh, "<", $infile;
open my $out_fh, ">", $outfile;

my %hash;
while (my $line = <$in_fh>) {
	chomp $line;
	$hash{$line}++;
}

for my $organism (sort keys %hash) {
	say $out_fh "$organism,$hash{$organism}";
}

close $in_fh;
close $out_fh;
