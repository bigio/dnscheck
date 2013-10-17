#!/usr/bin/perl 

# Giovanni Bechis, 2013-10-08
# dns configuration check

use strict;
use warnings;

use dnscheck::dns;

my $domain = shift;
my $resolver = shift;
my $auth_res;
my $pub_res;

if ( not defined $domain ) {
 die "usage: dnscheck domain [resolver]\n";
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
my @ns = &dnscheck::dns::find_ns($domain, $auth_res, $pub_res);
for my $i ( 0 .. @ns ) {
 if ( defined $ns[$i] ) {
  print $ns[$i]{'NS'};
  print " ( ";
  print $ns[$i]{'NS_RESOLVED'};
  print " )\n";
 }
}
if(&dnscheck::dns::check_cname($domain, $auth_res) ) {
  print "Error: record for domain $domain is a CNAME record\n";
}
