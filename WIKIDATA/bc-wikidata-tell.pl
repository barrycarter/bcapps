#!/bin/perl

# yet another attempt to make wikidata easy to index, recording the
# byte position of each entity (hopefully)

require "/usr/local/lib/bclib.pl";

open(A,"/mnt/squash/wikidata/latest-all.json");

my($pos) = 0;

while (<A>) {

  unless (/"id":"Q(\d+)"/) {warn "BAD LINE: $_"; next;}

  print "$pos $1\n";

  $pos = tell(A);

}


=item notes

big jump in numbering:

139088742898 92323324
139088757533 18

=cut

