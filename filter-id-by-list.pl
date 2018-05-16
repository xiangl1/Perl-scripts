#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature 'say';
use Getopt::Long;
use Pod::Usage;

main();

# --------------------------------------------------
sub main {
    my %args = get_args();

    if ($args{'help'} || $args{'man_page'}) {
        pod2usage({
            -exitval => 0,
            -verbose => $args{'man_page'} ? 2 : 1
        });
    }; 
	
	# get parameters
	my $main_file = $args{'input'} or pod2usage('Missing input file to be filtered');
	my $filter_file = $args{'filter'} or pod2usage('Missing filter list');
	my $outfile = $args{'out'} or pod2usage('Missing outfile name');
	my $type = $args{'type'} or pod2usage('Missing filter type: within or without');

	# open file
	open my $main_fh, "<", $main_file;
	open my $ex_fh, "<", $filter_file;
	open my $out_fh, ">", $outfile;

	# creat filter list hash
	my %ex_hash;
	while (my $line = <$ex_fh>) {
        chomp $line;
        $ex_hash{$line}++;
	}
	close $ex_fh;
	
	# filter main file
	# filter main file including the filter ids
	if ($type eq 'extract') {
		while (my $line = <$main_fh>) {
        	chomp $line;
        	say $out_fh "$line" if (exists $ex_hash{$line});
		}
	}
	if ($type eq 'exclude') {
		while (my $line = <$main_fh>) {
			chomp $line;
			say $out_fh "$line" unless (exists $ex_hash{$line});
		}
	}	

}

# --------------------------------------------------
sub get_args {
    my %args;
    GetOptions(
        \%args,
		'input=s',
		'filter=s',
		'out=s',
		'type=s',
        'help',
        'man',
    ) or pod2usage(2);

    return %args;
}

__END__

# --------------------------------------------------

=pod

=head1 NAME

filter-id-by-list.pl - a script

=head1 SYNOPSIS

  filter-id-by-list.pl -i [inputfile] -f [id list] -o [outputfile] -t [exclude or extract]

Options:

  --input	input file need be filtered
  --filter	filter list
  --out		output file name
  --type	"exclude" or "extract"
  --help	Show brief help and exit
  --man		Show full documentation

=head1 DESCRIPTION

Filter id list.

=head1 SEE ALSO

perl.

=head1 AUTHOR

Xiang Liu E<lt>Xiang@email.arizona.eduE<gt>.

=head1 COPYRIGHT

Copyright (c) 2018 Xiang

This module is free software; you can redistribute it and/or
modify it under the terms of the GPL (either version 1, or at
your option, any later version) or the Artistic License 2.0.
Refer to LICENSE for the full license text and to DISCLAIMER for
additional warranty disclaimers.

=cut
