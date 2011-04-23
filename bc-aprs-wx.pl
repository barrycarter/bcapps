#!/bin/perl

# Obtains weather data from the APRS stream <h>and does absolutely
# nothing with it</h>

require "bclib.pl";

open(A,"echo 'user READONLY pass -1' | ncat rotate.aprs.net 23 |");

# confirm connection
while (<A>) {
  debug($_);
  print STDERR "Diagnostic: $_\n)";
  if (/verified/i) {
    debug("CONFIRMED");
    last;
  }
}

for(;;) {
  $line = <A>;
#  debug($line);
  # TODO: this is an inaccurate and improper way to find weather data
  # 't' is case sensitive
  unless ($line=~/t\d{3}/) {next;}

#  debug($line);

  # get temperature
  $line=~/t(\d{3})/i;
  $temp = $1;

  # latitude/longitude
  unless ($line=~m%([\d\.]{3,})([N|S])/([\d\.]{3,})([E|W])%) {
    debug("BAD POS");
    next;
  }

  ($lat, $lats, $lon, $lons) = ($1, $2, $3, $4);

  # time
  unless ($line=~m%(\d{6})z%i) {
    debug("BAD TIME");
    next;
  }

  $time = $1;

  # "speaker"
  $line=~m%^(.*?)>%;
  $speaker = $1;

  # decimalize latitude/longitude (TODO: functionalize this)
  $latd = floor($lat/100);
  $latm = $lat - $latd*100;
  $latfinal = $latd+$latm/60;
  if ($lats eq "S") {$latfinal*=-1;}

  $lond = floor($lon/100);
  $lonm = $lon - $lond*100;
  $lonfinal = $lond+$lonm/60;
  if ($lons eq "W") {$lonfinal*=-1;}

  # figure out Unix time

  # xearth fun
  print "$latfinal $lonfinal ${temp}F\n";

  debug("LAT: $latd/$latm/$latsnr, LON: $lond/$lonm/$lonsnr");

#  print "$time $lat$lats $lon$lons $temp\n";

}


# @221533z2950.68N/09529.95W_308
