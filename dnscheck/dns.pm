#!/usr/bin/perl 

# ex:ts=8 sw=4:
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
	my $verbose = shift;
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
		if ( $verbose ) {
			warn "query failed: ", $pub_res->errorstring, "\n";
		}
	}
	return @result;
}

# Check if an host resolves as a CNAME
sub check_cname() {
	my $host = shift;
	my $auth_res = shift;
	my $verbose = shift;
	my $rr;
	my $query = $auth_res->search($host);

	if ($query) {
		foreach my $rr ($query->answer) {
			next unless $rr->type eq "CNAME";
			return 1;
  		}
	} else {
		if ( $verbose ) {
			warn "query failed: ", $auth_res->errorstring, "\n";
		}
	}
	return 0;
}

# Find authoritative name servers
sub find_ns() {
	my $domain = shift;
	my $auth_res = shift;
	my $pub_res = shift;
	my $verbose = shift;
	my @result;
	my @resolved;
	my $count = 0;

	my $query = $auth_res->query($domain, "NS");

	if ($query) {
		foreach my $rr (grep { $_->type eq 'NS' } $query->answer) {
			$result[$count]{'NS'} = $rr->nsdname;
			@resolved = &resolve_host( $rr->nsdname, $pub_res, $verbose );
			for my $i ( 0 .. (@resolved - 1) ) {
				$result[$count]{'NS_RESOLVED'} = $resolved[$i];
			}
			$count++;
		}
	} else {
		if ( $verbose ) {
			warn "query failed: ", $auth_res->errorstring, "\n";
		}
	}
	return @result;
}

# Find mail exchange servers
sub find_mx() {
	my $domain = shift;
	my $auth_res = shift;
	my $pub_res = shift;
	my $verbose = shift;
	my @mx;
	my @result;
	my $count = 0;

	@mx = mx($auth_res, $domain);
	if ( @mx ) {
		foreach my $rr ( @mx ) {
			$result[$count]{'MX'} = $rr->exchange;
			$count++;
		}
	} else {
		if ( $verbose ) {
			warn "Can't find MX records for $domain: ", $auth_res->errorstring, "\n";
		}
	}
	return @result;
}

# Find soa record
sub find_soa() {
	my $domain = shift;
	my $auth_res = shift;
	my $verbose = shift;
	my $rr;

	my $query = $auth_res->query($domain, "SOA");

	if ($query) {
		return ($query->answer)[0]->string;
	} else {
		if ( $verbose ) {
			warn "query failed: ", $auth_res->errorstring, "\n";
		}
		return -1;
	}
}

1;
