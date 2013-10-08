#!/usr/bin/perl 

use strict;
use warnings;

use Net::DNS;

my $domain = shift;
my $res   = Net::DNS::Resolver->new;

print &find_ns($domain);

sub resolve_host() {
 my $host = shift;
 my $result;
 my $rr;
 my $count = 0;
 my $query = $res->search($host);

 if ($query) {
  foreach my $rr ($query->answer) {
   next unless $rr->type eq "A";
   $result .= $rr->address;
   if ($count > 0) {
    $result .= " - ";
    $count++;
   }
  }
 } else {
  warn "query failed: ", $res->errorstring, "\n";
 }
 return $result;
}

sub find_ns() {
 my $domain = shift;
 my $result;
 my $rr;

 my $query = $res->query($domain, "NS");

 if ($query) {
  foreach $rr (grep { $_->type eq 'NS' } $query->answer) {
   $result .= "NS: " . $rr->nsdname . " ( " . &resolve_host($rr->nsdname) ." )\n";
  }
 } else {
  warn "query failed: ", $res->errorstring, "\n";
 }
 return $result;
}
