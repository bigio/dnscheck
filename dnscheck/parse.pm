#!/usr/bin/perl 

# ex:ts=8 sw=4:
# Giovanni Bechis, 2013-10-23
# dns record parsing functions
use strict;
use warnings;

package dnscheck::parse;

sub parse_soa() {
	my $soa_record = shift;
	my $tmp_soa_rec = '';
	my @a_tmp_soa;
	my @a_soa_l1;
	my @a_soa_l2;
	my %soa_info;

	@a_tmp_soa = split('\(', $soa_record);
	@a_soa_l1 = split(' ', $a_tmp_soa[0]);
	@a_soa_l2 = split(' ', $a_tmp_soa[1]);

	# Create an hash with some infos of the SOA record
	$soa_info{DOMAIN} = $a_soa_l1[0];
	$soa_info{NS} = $a_soa_l2[4];
	$soa_info{EMAIL} = $a_soa_l2[6];

	return %soa_info;
}

1;
