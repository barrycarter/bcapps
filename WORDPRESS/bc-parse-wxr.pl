#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";

use XML::Simple;

$xml = new XML::Simple;
$data = $xml->XMLin($ARGV[0]);

for $i (@{$data->{channel}->{item}}) {
  debug("I: $i");
}
