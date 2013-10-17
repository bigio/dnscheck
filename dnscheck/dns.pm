#!/usr/bin/perl 

# Giovanni Bechis, 2013-10-08
# dns configuration check
use strict;
use warnings;

package dnscheck::dns;

use Net::DNS;

# Resolve an host, returns an arrays of corresponding ip
sub resolve_host() {
 my $host = shift;
 my $pub_res = shift;
 my @result;
 my $rr;
 my $count = 0;
 my $query = $pub_res->search($host);

 if ($query) {
  foreach my $rr ($query->answer) {
   next unless $rr->type eq "A";
   $result[$count] = $rr->address;
   $count++;
  }
 } else {
  warn "query failed: ", $pub_res->errorstring, "\n";
 }
 return @result;
}

# Check if an host resolves as a CNAME
sub check_cname() {
 my $host = shift;
 my $auth_res = shift;
 my $rr;
 my $query = $auth_res->search($host);

 if ($query) {
  foreach my $rr ($query->answer) {
   next unless $rr->type eq "CNAME";
   return 1;
  }
 } else {
  warn "query failed: ", $auth_res->errorstring, "\n";
 }
 return 0;
}

# Find authoritative name servers
sub find_ns() {
 my $domain = shift;
 my $auth_res = shift;
 my $pub_res = shift;
 my @result;
 my @resolved;
 my $rr;
 my $count = 0;

 my $query = $auth_res->query($domain, "NS");

 if ($query) {
  foreach $rr (grep { $_->type eq 'NS' } $query->answer) {
   $result[$count]{'NS'} = $rr->nsdname;
   @resolved = &resolve_host($rr->nsdname, $pub_res);
   for my $i ( 0 .. (@resolved - 1) ) {
	$result[$count]{'NS_RESOLVED'} = $resolved[$i];
   }
   $count++;
  }
 } else {
  warn "query failed: ", $auth_res->errorstring, "\n";
 }
 return @result;
}

1;
