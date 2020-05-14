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

  # TODO: speed this up a LOT!

  # read backwards to previous newline

  my($n) = 1;

  do {
    seek(A, $rand-$n++, SEEK_SET);
    read(A, $buf, 1);
    } until ($buf eq "\n");

  # and then forward again until next newlie

  my($pos) = tell(A);
  my($data);
  my($len) = 0;

  debug("FOUND START OF LINE: $pos");

  do {
    seek(A, $pos+$len++, SEEK_SET);
    read(A, $buf, 1);
    $data .= $buf;
  } until ($buf eq "\n");

  $data=~s/\,$//;

  my($hashref) = JSON::from_json($data);

  debug("READ:", $hashref->{id});

  # read rest of line

#  my($eol) = <A>;

  # and print it (for now)

#  debug("EOL: $eol");

}
