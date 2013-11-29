#!/usr/bin/perl -w

# ex:ts=8 sw=4:

use strict;
use CGI qw(:standard);
use FindBin;
use lib ("$FindBin::Bin");

use Net::DNS;
use Net::IP;

use dnscheck::dns;
use dnscheck::parse;

my $domain;
my $auth_res;
my $pub_res;
my $resolver;
my $verbose = 0;
my $query = new CGI;

# Print correct headers
print $query->header("text/html");
print $query->start_html("DNS configuration check");
print $query->start_form(-method=>"POST",
			-action=>"dnscheck.cgi");
print "Dominio: ". $query->textfield(-name=>"dom");
print "Server dns: " . $query->textfield(-name=>"resolver");
print $query->submit(-name=>"dnscheck",
		    -value=>"check dns configuration");
print $query->end_form;

# Read POST parameters
$domain = $query->param('dom');
$resolver = $query->param('resolver');

if ( defined $domain ) {
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
	my @ns = &dnscheck::dns::find_ns($domain, $auth_res, $pub_res, $verbose);
	print "NS records for domain " . $domain . "<br>\n";
	for my $i ( 0 .. @ns ) {
		if ( defined $ns[$i] ) {
			print $ns[$i]{'NS'};
			print " ( ";
			print $ns[$i]{'NS_RESOLVED'};
			print " )<br>\n";
		}
	}
	if ( not defined $ns[0] ) {
		print "No nameservers available for domain $domain\n";
	}
	print "<br>\n";
} else {
	print "Please specify a domain name<br>\n";
}

print $query->end_html;
