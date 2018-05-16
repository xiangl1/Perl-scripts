#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature 'say';
use Getopt::Long;
use Pod::Usage;
use LWP::Simple;

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

    # get parameters (query,database,rettype, and output file)
    my $input = $args{'input'} or pod2usage('Missing query strings or acc list file');
	my $db = $args{'db'} || 'protein';
    my $rettype = $args{'rettype'} || 'acc';
    my $outfile = $args{'out'} or pod2usage('Missing outfile name');
	my $base = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/';	
	# retrieve by accession number list
    if ( -s $input) {
    open my $in_fh, "<", $input;
    my @acc_list;
    while (my $acc = <$in_fh>) {
        chomp $acc;
        push @acc_list, $acc;
    }
    close $in_fh;
    my $total = scalar @acc_list;

    open my $out_fh, ">", $outfile;

    my $batch = 50;

    for (my $start = 0; $start < $total+$batch;$start+=$batch) {
        my $end = $start + $batch;
        my $id_list="";
        if ($end < $total) {
             $id_list = join(",", @acc_list[$start .. $end-1]);
        } else {
             $id_list = join(",", @acc_list[$start .. $total-1]);
        }
        my $efetch_url = $base."efetch.fcgi?db=protein&id=$id_list&rettype=$rettype&retmode=text";
        my $efetch_out = get($efetch_url);
        say $out_fh "$efetch_out";
    }
    close $out_fh;
    }  else {
	# retrieve by NCBI esearch term
		retrieve ($input, $db, $rettype, $outfile);
	}

}

# --------------------------------------------------
sub retrieve {
	# assemble the esearch URL
	my ($query, $db, $rettype,$outfile) = @_;
    my $base = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
    my $url = $base . "esearch.fcgi?db=$db&term=$query&usehistory=y";

    # post the esearch URL

    my $output = get($url);

    #parse WebEnv, QueryKey and Count (# records retrieved)
    my $web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
    my $key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
    my $count = $1 if ($output =~ /<Count>(\d+)<\/Count>/);

	# open output file for writing
	open my $out_fh, ">", $outfile;

	# retrieve data in batches of 500

	my $retmax = 500;
	for (my $retstart = 0; $retstart < $count; $retstart += $retmax) {
        my $efetch_url = $base ."efetch.fcgi?db=$db&WebEnv=$web";
        $efetch_url .= "&query_key=$key&retstart=$retstart";
        $efetch_url .= "&retmax=$retmax&rettype=$rettype&retmode=text";
        my $efetch_out = get($efetch_url);
        say $out_fh "$efetch_out";
	}
	close $out_fh;
}

# --------------------------------------------------
sub get_args {
    my %args;
    GetOptions(
        \%args,
        'input=s',
		'db=s',
		'rettype=s',
		'out=s',
		'help',
        'man',
    ) or pod2usage(2);

    return %args;
}

__END__

# --------------------------------------------------

=pod

=head1 NAME

ncbi-eutility-download.pl - a script

=head1 SYNOPSIS

	ncbi-eutility-download.pl -i [search term or acc list] -d [database] -rettype [efetch rettype]
	 -o [output file name]

Options:

  --input		NCBI E-utility formatted search term or file with accession number list
  --db     		NCBI E-utility database (default: protein)
  --rettype		NCBI efetch rettype (default: acc)
  --out			output file name
  --help   		Show brief help and exit
  --man    		Show full documentation
  
=head1 DESCRIPTION

This scripts includs NCBI esearch and efetch, can be used to download fasta and acc number form NCBI in protein and nocletide database with search esearch formatted term.

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
