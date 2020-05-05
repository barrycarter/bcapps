#!/bin/perl

# reads wikidata from wikidata dumps

# JSON->{'claims'}->{'P31'}->[0]->{'mainsnak'}->{'datavalue'}->{'value'}->{'id'}
# = 'Q3336843';

require "/usr/local/lib/bclib.pl";

while (<>) {

  # ignore "[" line, if any
  # TODO: more generalize ignore routine here
  if (/^\[|\]$/) {next;}

  s/\,$//;

  my($json) = JSON::from_json($_);

  my($id) = $json->{id};

  debug("ID: $json->{id}");

  my(@p31) = @{$json->{'claims'}->{'P31'}};

  for $i (@p31) {
      my($target) = $i->{'mainsnak'}->{'datavalue'}->{'value'}->{'id'};
      print "$id P31 $target\n";
  }


  my(@p279) = @{$json->{'claims'}->{'P279'}};

  for $i (@p279) {
      my($target) = $i->{'mainsnak'}->{'datavalue'}->{'value'}->{'id'};
      print "$id P279 $target\n";
  }
}

die "TESTING";

read(A,$buf,1000000);

$buf=~s/\{\"id\":\"Q8\".*$//s;
$buf=~s/^\[//;
$buf=~s/,$//;

debug(var_dump("hash",JSON::from_json($buf)));

=item comment

Useful entity things (JSON is object)

JSON->{'aliases'}->{'en'}->[0]->{'value'} = 'cosmos'; 
JSON->{'aliases'}->{'en'}->[1]->{'value'} = 'The Universe'; 

# P1036 is Dewey Decimal Classification
JSON->{'claims'}->{'P1036'}->[0]->{'mainsnak'}->{'datavalue'}->{'value'} = '113\';

JSON->{'descriptions'}->{'en'}->{'value'} = 'totality of planets, stars, galaxies, intergalactic space, or all matter or all energy';

JSON->{'labels'}->{'en'}->{'value'} = 'universe';

JSON->{'sitelinks'}->{'enwiki'}->{'title'} = 'Universe';

JSON->{'type'} = 'item';

=cut

=item comment

If using beta dump in TTL format (eg,
wikidata-20161226-all-BETA.ttl.bz2), this gives Q items with names

bzgrep -A 1 '^wd:Q[0-9]* a' wikidata-20161226-all-BETA.ttl.bz2

If you have a TSV file where you need to identify various Qs (mine is
dead2.tsv for dead musicians)

perl -anle '$F[0]=~/(Q\d+)\>$/; print "wd:$1 a"' dead2.tsv | sort -u > grepme.txt

and then fgrep -f

=cut
