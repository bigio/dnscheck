#!/usr/bin/perl 
 
# ex:ts=8 sw=4:
# Giovanni Bechis, 2013-10-08
# dns configuration check

use strict;
use warnings;
use Getopt::Std;

use FindBin;
use lib ("$FindBin::Bin");

use Net::DNS;
use Net::IP;

use dnscheck::dns;
use dnscheck::parse;

my $domain;
my $resolver;
my $verbose = 0;
my $auth_res;
my $pub_res;
my %soa_info;
my %opts = ();

getopts('v', \%opts);
if ( defined $opts{v} ) {
	$verbose = 1;
}
$domain = shift;
$resolver = shift;

if ( not defined $domain ) {
	die "usage: dnscheck domain [authoritative domain server]\n";
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
print "NS records for domain " . $domain . "\n";
for my $i ( 0 .. @ns ) {
	if ( defined $ns[$i] ) {
		print $ns[$i]{'NS'};
		print " ( ";
		print $ns[$i]{'NS_RESOLVED'};
		print " )\n";
	}
}
print "\n";

# Tests on dns records
print "record for domain should not be a CNAME...\t";
if( &dnscheck::dns::check_cname( $domain, $auth_res ) ) {
	print "KO\n";
} else {
	print "OK\n";
}

print "NS records should not be a CNAME...\t\t";
my $ns_cname_check = 0;
for my $i ( 0 .. @ns ) {
	if ( defined $ns[$i] ) {
		if( &dnscheck::dns::check_cname( $ns[$i]{'NS'}, $auth_res ) ) {
			$ns_cname_check = 1;
		} else {
			$ns_cname_check = 0;
		}
	}
}
if( $ns_cname_check ) {
	print "KO\n";
} else {
	print "OK\n";
}

print "MX records should not be a CNAME...\t\t";
my @mx = &dnscheck::dns::find_mx( $domain, $auth_res, $pub_res );
my $mx_cname_check = 0;
for my $i ( 0 .. @ns ) {
	if ( defined $mx[$i] ) {
		if( &dnscheck::dns::check_cname( $mx[$i]{'MX'}, $auth_res ) ) {
			$mx_cname_check = 1;
		} else {
			$mx_cname_check = 0;
		}
	}
}
if( $mx_cname_check ) {
	print "KO\n";
} else {
	print "OK\n";
}

# tests on soa record
%soa_info = &dnscheck::parse::parse_soa(&dnscheck::dns::find_soa($domain, $auth_res));
print "soa record checks...\t\t\t\t";
if ( not defined $soa_info{NS} ) {
	print "KO";
	if ( $verbose ) {
		print " (soa query has failed)";
	}
	print "\n";
} elsif ( ( Net::IP::ip_is_ipv4($soa_info{NS}) ) ) {
	print "KO";
	if ( $verbose ) {
		print " (nameserver in soa record should not be an ip address)";
	}
	print "\n";
} else {
	print "OK\n";
}
