#!/bin/perl

# Trivial script to parse metadata files in ghcnd_all

require "/usr/local/lib/bclib.pl";

=item unix

The following Unix commands to determine which stations have both TMAX
and TMIN data for the same years.

fgrep TMAX ghcnd-inventory.txt | sort > stations-with-tmax.txt.srt
fgrep TMIN ghcnd-inventory.txt | sort > stations-with-tmin.txt.srt

: this join auto excludes stations that have TMAX or TMIN but not both

: below shows 33770 stations with both TMAX and TMIN

join stations-with-tmax.txt.srt stations-with-tmin.txt.srt | wc

: below shows 1555 of those stations have different year ranges for
: TMAX and TMIN

join stations-with-tmax.txt.srt stations-with-tmin.txt.srt | perl -anle 'unless ($F[4] == $F[9] && $F[5] == $F[10]) {print "BAD: $_"}' | wc

: i am comfortable with ignoring those stations, so...

join stations-with-tmax.txt.srt stations-with-tmin.txt.srt | perl -anle 'if ($F[4] == $F[9] && $F[5] == $F[10]) {print $_}' | sort > join1.txt

: we could do this final join in code, but its nice to see what it looks like

sort ghcnd-stations.txt | join --check-order join1.txt - > join3.txt

=cut

# use Unix join command to get latitude/longitude/data years/name all
# at once, hopefully

# TODO: this is ugly, though I think it will work

# TODO: using TMAX data as canonical, which it should be except for
# years included, where I'll just pretend it is; however, it turns out
# there is TMIN for 33917 stations and TMAX for 34015, so, yes, there
# is a disconnect here; maybe only use stations that have both?

# NOTE: must created sorted files, join won't work otherwise

open(A, "join3.txt");

while (<A>) {

  my($code, $lat, $lon, $tmax, $syear, $eyear, $lat2, $lon2, $tmin,
  $syear2, $eyear2, $lat3, $lon3, $el, @rest) = split(/\s+/, $_);

  # sanity checking
  unless ($tmax eq "TMAX" && $tmin eq "TMIN" &&
	  $lat == $lat2 && $lon == $lon2 && $lat == $lat3 && $lon == $lon3 &&
	  $syear == $syear2 && $eyear == $eyear2) {
    die "WTF: $_";
  }

  my($location) = join(" ",@rest);
  my($cc) = substr($code,0,2);

  print join("\t", ($cc, $code, $lat, $lon, $el, $syear, $eyear, $location)),"\n";

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
