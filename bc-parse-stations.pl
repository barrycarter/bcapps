#!/bin/perl

# Parses the latest version of
# http://weather.noaa.gov/data/nsd_cccc.txt (they've made
# changes/corrections) and puts it into station table

# I've humorously annotated some entries, and am storing the
# annotations in MIME64 (which means you can see them if you want, but
# don't have to spoiled if you don't want to be; considered rot 13
# too..)

require "bclib.pl";
open(A,"db/nsd_cccc_annotated.txt");

while (<A>) {
  # hack to find my annotations
  chomp($_);
  s/\r//isg;
  if (s/\;\"(.*?)\"$//) {
    $ann=$1;
    $ann=encode_base64($ann);
    $ann=~s/\s//isg;
    debug("ANN: $ann");
  } else {
    $ann="";
  }

  # x1, x2 = unknown (to me)
  my($indi,$wmob,$wmos,$place,$state,$country,$wmoregion,$lat,$lon,$x1,$x2,$elev) = split(/\;/, $_);

#  debug($wmob,$wmos,$indi,$place,$state,$country,$wmoregion,$lat,$lon,$x1,$x2,$elev);

  # convert lat to decimal (probably much better ways to do this!)
  if ($lat=~/^(\d{2})\-(\d{2})(N|S)/) {
    ($lad,$lam,$las,$lax)=($1,$2,0,$3);
  } elsif ($lat=~/^(\d{2})\-(\d{2})\-(\d{2})(N|S)/) {
    ($lad,$lam,$las,$lax)=($1,$2,$3,$4);
  } else {
    die("BAD LAT: $lat");
  }

  $flat=$lad+$lam/60+$las/3600;
  if ($lax eq "S") {$flat=-$flat;}

  if ($lon=~/^(\d{2,3})\-(\d{2})(E|W)/) {
    ($lod,$lom,$los,$lox)=($1,$2,0,$3);
  } elsif ($lon=~/^(\d{2,3})\-(\d{2})\-(\d{2})(E|W)/) {
    ($lod,$lom,$los,$lox)=($1,$2,$3,$4);
  } else {
    die("BAD LON: $lon");
  }

  $flon=$lod+$lom/60+$los/3600;
  if ($lox eq "W") {$flon=-$flon;}

  # 3D coords (earth radius = 1) [on the theory they might be helpful
  # somewhere/somehow/someday]
  # TODO: include elevation?
  ($x,$y,$z) = sph2xyz($flon,$flat,1);

  # print in importable format (for sqlite3)
  print join("\t", ($indi, $wmob, $wmos, $place, $state, $country, $flat, $flon, $elev, $x, $y, $z, $ann)),"\n";
}

=item schema

CREATE TABLE stations (
 metar TEXT,
 wmob INT,
 wmos INT,
 city TEXT,
 state TEXT,
 country TEXT,
 latitude DOUBLE,
 longitude DOUBLE,
 elevation DOUBLE,
 x DOUBLE,
 y DOUBLE,
 z DOUBLE,
 humor TEXT
);

CREATE INDEX i_metar ON stations(metar);
CREATE INDEX i_x ON stations(x);
CREATE INDEX i_y ON stations(y);
CREATE INDEX i_z ON stations(z);

=cut

