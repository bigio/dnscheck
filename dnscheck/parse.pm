#!/usr/bin/perl 

# Giovanni Bechis, 2013-10-23
# dns record parsing functions
use strict;
use warnings;

package dnscheck::parse;

sub parse_soa() {
 my $soa_record = shift;
 my $tmp_soa_rec = '';
 my @a_tmp_soa;
 my @a_soa;
 my %soa_info;

 @a_tmp_soa = split('\(', $soa_record);
 @a_soa = split(' ', $a_tmp_soa[0]);
 
 # Create an hash with some infos of the SOA record
 $soa_info{DOMAIN} = $a_soa[0];
 $soa_info{NS} = $a_soa[4];
 $soa_info{EMAIL} = $a_soa[5];

 return %soa_info;
}

1;
