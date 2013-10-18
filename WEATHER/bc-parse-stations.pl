#!/bin/perl

# Parses the latest version of
# http://weather.noaa.gov/data/nsd_cccc.txt and 
# http://www.rap.ucar.edu/weather/surface/stations.txt
# but only after parsing MLI list which trumps these lists

# -noprint: don't print anything (useful for debugging)

require "/usr/local/lib/bclib.pl";

# which METAR are already in stations.db?
@res = sqlite3hashlist("SELECT metar FROM stations","/sites/DB/stations.db");
for $i (@res) {$seen{$i->{metar}}=1;}

open(A, "fgrep stn= /home/barrycarter/BCGIT/WEATHER/meso_station.cgi.html|");

# cols where data is
@cols = (74, 83, 119, 122, 134, 147, 158);

while (<A>) {
  my(@data) = column_data($_, [@cols]);
  # clean data
  for $i (@data) {
    $i=~s/<.*?>//isg;
    $i=~s/ft//isg;
    $i = trim($i);
  }

  debug("DATA",@data);
  # print for stations.db
  print join("\t", @data)."\n";
}








die "TESTING";



open(A,"/home/barrycarter/BCGIT/WEATHER/nsd_cccc_annotated.txt");

while (<A>) {
  # x1, x2 = useless to me
  my($indi,$wmob,$wmos,$place,$state,$country,$wmoregion,$lat,$lon,$x1,$x2,$elev) = split(/\;/, $_);
  # seen by MLI? if so, ignore
  if ($seen{$indi}) {next;}
  # record that we've seen this station
  $seen{$indi}=1;

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

  # correct elevation, combo field for WMO
  $elev = round2(convert($elev,"m","ft"));
  $wmobs = $wmob*1000+$wmos;

  # print in importable format (for sqlite3)
  print join("\t", ($indi, $wmobs, $place, $state, $country, $flat, $flon, $elev, "http://weather.noaa.gov/data/nsd_cccc.txt")),"\n";
}

close(A);

# now, parse stations.txt (the UCAR list)
# columns where data starts (not actually all data, just start/end cols I need)
@cols = (0, 3, 20, 26, 32, 39, 47, 55, 61, 80, 99);
open(A,"/home/barrycarter/BCGIT/WEATHER/stations.txt");

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
  ($state, $name, $code, $iata, $synop, $lat, $lon, $elev, $junk, $country) = @data;

  debug("JUNK: $junk, COUNTRY: $country");

  # ignore blank codes and seen codes and header "ICAO" code
  if ($code=~/^\s*$/ || $seen{$code} || $code=~/^ICAO$/) {next;}

  # third col test above insufficient; if $code starts with number, ignore
  if ($code=~/^\d/) {next;}

#  debug("LAT: $lat, LONG: $lon");

  # icky code copying from above, except "-" becomes " "
  # convert lat to decimal (probably much better ways to do this!)
  if ($lat=~/^(\d{2})\s(\d{2})(N|S)/) {
    ($lad,$lam,$las,$lax)=($1,$2,0,$3);
  } elsif ($lat=~/^(\d{2})\s(\d{2})\s(\d{2})(N|S)/) {
    ($lad,$lam,$las,$lax)=($1,$2,$3,$4);
  } else {
    warn("BAD LAT: $lat");
  }

  $flat=$lad+$lam/60+$las/3600;
  if ($lax eq "S") {$flat=-$flat;}

  if ($lon=~/^(\d{2,3})\s(\d{2})(E|W)/) {
    ($lod,$lom,$los,$lox)=($1,$2,0,$3);
  } elsif ($lon=~/^(\d{2,3})\s(\d{2})\s(\d{2})(E|W)/) {
    ($lod,$lom,$los,$lox)=($1,$2,$3,$4);
  } else {
    warn("BAD LON: $lon");
  }

  $flon=$lod+$lom/60+$los/3600;
  if ($lox eq "W") {$flon=-$flon;}

  # correct elevation
  $elev = round2(convert($elev,"m","ft"));

  # print in importable format (for sqlite3)
  print join("\t", ($code, $wmobs, $name, $state, $country, $flat, $flon, $elev, "http://www.rap.ucar.edu/weather/surface/stations.txt")),"\n";
}

close(A);

=item schema

CREATE TABLE stations ( 
 metar TEXT,
 wmobs INT, 
 city TEXT, 
 state TEXT, 
 country TEXT, 
 latitude DOUBLE, 
 longitude DOUBLE, 
 elevation DOUBLE,
 source TEXT 
);

CREATE INDEX i_metar ON stations(metar);

.separator "\t"
.import /path/to/output/of/this/program stations

=cut

