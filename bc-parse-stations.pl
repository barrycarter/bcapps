#!/bin/perl

# Parses the latest version of
# http://weather.noaa.gov/data/nsd_cccc.txt (they've made
# changes/corrections) and puts it into station table

# I've humorously annotated some entries, and am storing the
# annotations in MIME64 (which means you can see them if you want, but
# don't have to spoiled if you don't want to be; considered rot 13
# too..)

# 05 Apr 2012: Greg Thompson's
# http://www.rap.ucar.edu/weather/surface/stations.txt includes METAR
# stations that nsd_cccc.txt doesn't, so adding them as well (but only
# when they don't appear in nsd_cccc.txt already)

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

  # record that we've seen this station
  $seen{$indi}=1;

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
  ($x,$y,$z) = sph2xyz($flon,$flat,1,"degrees=1");

  # print in importable format (for sqlite3)
  print join("\t", ($indi, $wmob, $wmos, $place, $state, $country, $flat, $flon, $elev, $x, $y, $z, $ann)),"\n";
}

close(A);

debug("PART TWO");

# now, parse stations.txt
# columns where data starts
@cols = (0, 3, 20, 26, 32, 39, 47, 55, 61);
open(A,"db/stations.txt");

while (<A>) {
  # ignore comments (start with "!") and blank lines
  if (/^\!/ || /^\s*$/) {next;}

  # if third column is non-blank, this is a header line, not a data line
  unless (substr($_,2,1)=~/\s/) {next;}

  # get data from columns
  @data=();
  for $j (0..$#cols) {
    $item = substr($_, $cols[$j], $cols[$j+1]-$cols[$j]);
    $item=trim($item);
    push(@data,$item);
  }

  # assign data to vars
  ($state, $name, $code, $iata, $synop, $lat, $long, $elev) = @data;

  # ignore blank codes and seen codes
  if ($code=~/^\s*$/ || $seen{$code}) {next;}

  # third col test above insufficient; if $code starts with number, ignore
  if ($code=~/^\d/) {next;}

  # if synop, split into wmob/wmos
  if ($synop=~/^(..)(...)$/) {
    ($wmob,$wmos) = ($1,$2);
  } else {
    ($wmob,$wmos) = ("","");
  }

  # print in importable format (for sqlite3)
  print join("\t", ($station, $wmob, $wmos, $place, $state, $country, $flat, $flon, $elev, $x, $y, $z, $ann)),"\n";
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

.separator "\t"
.import /path/to/output/of/this/program stations

=cut

