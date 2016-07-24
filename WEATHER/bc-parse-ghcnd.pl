#!/bin/perl

# Trivial script to parse metadata files in ghcnd_all

require "/usr/local/lib/bclib.pl";

# use Unix join command to get latitude/longitude/data years/name all
# at once, hopefully

# TODO: this is ugly, though I think it will work

# TODO: using TMAX data as canonical, which it should be except for
# years included, where I'll just pretend it is

open(A, "join ghcnd-inventory.txt ghcnd-stations.txt | fgrep ' TMAX '|");

while (<A>) {

  my($name, $lat, $lon, $tmax, $syear, $eyear, $lat2, $lon2, $el, @rest) = 
    split(/\s+/, $_);

  my($location) = join(" ",@rest);

}

die "TESTING";

open(A,"ghcnd-stations.txt")||die("Can't open, $!");
open(B,">ghcnd-stations.tsv");

while (<A>) {

  # the overlap below between country code and station code is intentional

  my(@fields) = (get_chars($_,1,2), get_chars($_,1,11),
  get_chars($_,13,20), get_chars($_,22,30), get_chars($_,32,37),
  get_chars($_,39,40), get_chars($_,42,71), get_chars($_,81,85));

  map($_=trim($_), @fields);
  map(s/\"//g, @fields);
  $fields[6]=~s/(\w+)/ucfirst(lc($1))/eg;

  print B join("\t",@fields),"\n";
}

close(A);
close(B);



open(A,"ghcnd-states.txt")||die("Can't open, $!");
open(B,">ghcnd-states.tsv");

while (<A>) {

  my(@fields) = (get_chars($_,1,2), get_chars($_,4,50));

  map($_=trim($_), @fields);
  map(s/\"//g, @fields);
  $fields[1]=~s/(\w+)/ucfirst(lc($1))/eg;

  print B join("\t",@fields),"\n";
}

close(A);
close(B);

=item comment

From README file, ghcnd-stations.txt is:

ID            1-11   Character
LATITUDE     13-20   Real
LONGITUDE    22-30   Real
ELEVATION    32-37   Real
STATE        39-40   Character
NAME         42-71   Character
GSN FLAG     73-75   Character
HCN/CRN FLAG 77-79   Character
WMO ID       81-85   Character

ghcnd-states.txt:

CODE          1-2    Character
NAME         4-50    Character

ghcnd-countries.txt

CODE          1-2    Character
NAME         4-50    Character

=cut

sub get_chars {
  my($str,$x,$y) = @_;
  return substr($str,$x-1,$y-$x+1);
}
