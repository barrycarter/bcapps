#!/bin/perl

# reads wikidata from the 45G 20150525.json file

require "/usr/local/lib/bclib.pl";

open(A,"/home/barrycarter/20150530/20150525.json");

# this skips the "[" line
<A>;

while (<A>) {
  chomp();
  s/\,$//;
#  debug("THUNK: $_");
  my($json) = JSON::from_json($_);
  debug(var_dump("JSON",$json));
  die "TESTING";
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
