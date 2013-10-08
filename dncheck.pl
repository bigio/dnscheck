#!/usr/bin/perl 

use strict;
use warnings;

use Net::DNS;

my $domain = shift;
my $res   = Net::DNS::Resolver->new;

print &find_ns($domain);

sub find_ns() {
 my $domain = shift;
 my $result;
 my $rr;

 my $query = $res->query($domain, "NS");

 if ($query) {
  foreach $rr (grep { $_->type eq 'NS' } $query->answer) {
   $result .= "NS: " . $rr->nsdname . "\n";
  }
 } else {
  warn "query failed: ", $res->errorstring, "\n";
 }
 return $result;
}
