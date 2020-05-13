#!/bin/perl

# seeks inside the uncompressed (but on squashfs so really is
# compressed) latest-all.json file for wikidata

require "/usr/local/lib/bclib.pl";

open(A,"/mnt/squash/wikidata/latest-all.json");

debug("FILE OPENED");

# TODO: dont hardcode size

my($size) = 1121233370788;

for $i (1..1) {

  # pick a random number inside file

  my($rand) = round(rand()*$size);

  debug("RAND: $rand");

  # seek there and read rest of line

  seek(A, $rand, SEEK_SET);

  debug("SEEK COMPLETED");

  # read rest of line

  my($eol) = <A>;

  # and print it (for now)

  debug("EOL: $eol");

}



  
