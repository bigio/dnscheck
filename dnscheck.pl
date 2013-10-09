#!/usr/bin/perl 

# Giovanni Bechis, 2013-10-08
# dns configuration check

use strict;
use warnings;

use Net::DNS;

my $domain = shift;
my $resolver = shift;
my $auth_res;
my $pub_res;

if ( not defined $domain ) {
 die "usage: dnscheck domain [resolver]\n";
}


# Resolve an host, returns an arrays of corresponding ip
sub resolve_host() {
 my $host = shift;
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

# Find authoritative name servers
sub find_ns() {
 my $domain = shift;
 my @result;
 my @resolved;
 my $rr;
 my $count = 0;

 my $query = $auth_res->query($domain, "NS");

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
  warn "query failed: ", $auth_res->errorstring, "\n";
 }
 return @result;
}

# Main function

# Use a different resolver for authoritative queries if specified
if ( defined $resolver ) {
 $auth_res = Net::DNS::Resolver->new(
	nameservers => [ $resolver ],
	recurse => 0,
 );
} else {
 $auth_res = Net::DNS::Resolver->new;
}

# Use the standard resolver for not authorative queries
$pub_res = Net::DNS::Resolver->new;

# Find ns and print them with their ip
my @ns = &find_ns($domain);
for my $i ( 0 .. @ns ) {
 if ( defined $ns[$i] ) {
  print $ns[$i]{'NS'};
  print " ( ";
  print $ns[$i]{'NS_RESOLVED'};
  print " )\n";
 }
}
