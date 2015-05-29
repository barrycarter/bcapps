#!/bin/perl

# simple CLI to wikidata's API

require "/usr/local/lib/bclib.pl";

my($out,$err,$res);

# if query starts with capital Q, show data

if ($ARGV[0]=~/^Q\d+$/) {
  ($out,$err,$res) = cache_command2("curl 'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$ARGV[0]&languages=en&format=xml'", "age=86400");
  debug("OUT: $out");
  exit;
}

if ($ARGV[0]=~/^P\d+$/) {
  ($out,$err,$res) = cache_command2("curl 'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$ARGV[0]&languages=en&format=xml'", "age=86400");
  debug("OUT: $out");
  exit;
}

# given query, show results

($out,$err,$res) = cache_command2("curl 'https://www.wikidata.org/w/api.php?action=wbsearchentities&language=en&search=$ARGV[0]&format=xml'", "age=86400");

while ($out=~s/<(entity .*?)>//) {
  my($data) = $1;

  my(%hash);

  while ($data=~s/(\S+)\s*\=\s*\"(.*?)\"//i) {
    $hash{$1}=$2;
  }

  print unidecode("$hash{id} $hash{label} $hash{description}\n");

}

# debug("OUT: $out");
