#!/usr/bin/perl 

use strict;
use warnings;

use Net::DNS;

my $domain = shift;
my $res   = Net::DNS::Resolver->new;

sub resolve_host() {
 my $host = shift;
 my @result;
 my $rr;
 my $count = 0;
 my $query = $res->search($host);

 if ($query) {
  foreach my $rr ($query->answer) {
   next unless $rr->type eq "A";
   $result[$count] = $rr->address;
   $count++;
  }
 } else {
  warn "query failed: ", $res->errorstring, "\n";
 }
 return @result;
}

sub find_ns() {
 my $domain = shift;
 my @result;
 my @resolved;
 my $rr;
 my $count = 0;

 my $query = $res->query($domain, "NS");

 if ($query) {
  foreach $rr (grep { $_->type eq 'NS' } $query->answer) {
   $result[$count]{'NS'} = $rr->nsdname;
   @resolved = &resolve_host($rr->nsdname);
   for my $i ( 0 .. (@resolved - 1) ) {
	$result[$count]{'NS_RESOLVED'} = $resolved[$i];
   }
   $count++;
  }
 } else {
  warn "query failed: ", $res->errorstring, "\n";
 }
 return @result;
}

my @ns = &find_ns($domain);
for my $i ( 0 .. @ns ) {
 if ( defined $ns[$i] ) {
  print $ns[$i]{'NS'};
  print " ( ";
  print $ns[$i]{'NS_RESOLVED'};
  print " )\n";
 }
}
