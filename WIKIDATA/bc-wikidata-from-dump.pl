#!/bin/perl

# reads wikidata from wikidata dumps

# JSON->{'claims'}->{'P31'}->[0]->{'mainsnak'}->{'datavalue'}->{'value'}->{'id'}
# = 'Q3336843';

require "/usr/local/lib/bclib.pl";

sub handle_string {
    my($str) = @_;
    my(%hash);

    debug("STR: $str");

    while ($str=~s/\"([^\"]*?)\":\[(.*?)\]//) {
	debug("ALPHA: $1 $2");
    }
    
    while ($str=~s/\"(.*?)\":\"(.*?)\"//) {
	debug("GAMMA: $1 $2");
    }
    
    unless ($str=~/^[\s\,]*$/) {
	warn("BAD STRING: $str");
    }

#    debug("STRBETA: $str");

#    for $i (csv($str)) {
#	debug("I: $i");
#	unless ($i=~s/^\"(.*?)\":\"(.*?)\"$//) {
#           warn "BAD STRING: $i";
#	}
#    }
}

while (<>) {

    chomp;

    # ignore "[" line, if any (thats the start of a huge JSON array)
    # TODO: more generalize ignore routine here
    if (/^\[|\]$/) {next;}

    # find minmal braces
    s/\{([^\{\}]*)\}/handle_string($1)/iseg;

    # warn testing
    next;

    # ignore the command that ends the line (between array elements)
    s/\,$//;

    s/(\}\,)/$1\n/sg;

    debug("LENG", length($_));

    debug($_);

    $_ = read_file("/tmp/fuckme.txt");

    my($json) = new JSON;

    $json = $json->max_size(1e+9);
    $json = $json->max_depth(10000);
    debug("MD", $json->get_max_depth);
    debug("MS", $json->get_max_size);

    $json = JSON::from_json($_);






    debug(var_dump("hash",JSON::from_json($buf)));

  # TESTING!
    next;

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
