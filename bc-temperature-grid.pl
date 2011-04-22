#!/bin/perl

# colors google map using "grid" of temperatures
# TODO: make grid change w/ zoom level (== hard?)

push(@INC,"/usr/local/lib");
require "bclib.pl";
chdir(tmpdir());
system("pwd");

system("cp /sites/DB/metar.db .");
@res = sqlite3hashlist("SELECT -strftime('%s', replace(n.time, '-4-','-04-'))+strftime('%s', 'now') AS age, n.code, n.temperature, s.latitude, s.longitude FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE age>0 AND age<7200 AND temperature IS NOT NULL", "metar.db");

# go through all stations
for $i (@res) {
  %hash = %{$i};

  # for now, just latitude and longitude, later more accurate
  ($lat, $lon) = (floor($hash{latitude}), floor($hash{longitude}));

  # push to list of temperatures for this lat/lon
  push(@{$temps{"$lat,$lon"}}, $hash{temperature});
}

# fly script
open(A,">flyscript");

# size (y is 170 since google maps lat -85 to +85)
# setpixel below solely because we need to make black transparent
print A "new\nsize 360,170\nsetpixel 0,0,0,0,0\n";

for $i (sort keys %temps) {
  @temps = @{$temps{$i}};

  # find average temp
  $sum=0;
  for $j (@temps) {$sum+=$j;}
  $avg = $sum/($#temps+1);

  # convert to F and find my own hue (not official)
  $f = $avg*1.8+32;
  $hue = 5/6-($f/100)*5/6;
  $rgb = hsv2rgb($hue,1,1,"format=decimal");
  debug("$f -> $hue -> $rgb");

  # the xy coords for fly (lat = -85 to +85 to avoid google maps issues)
  ($lat,$lon) = split(",",$i);

  $x = ($lon+180);
  $y = (85-$lat);

  print A "setpixel $x,$y,$rgb\n";

  debug("$i -> $rgb");
}

close(A);

# keep a copy of this for debugging
system("cp flyscript /tmp");
system("fly -q -i flyscript -o opaque.png");
system("convert -transparent black opaque.png transparent.png");
# make fg colors semi-transparent
# more direct way to do this, not "Divide 10"?
system("convert transparent.png -channel Alpha -evaluate Divide 2 semitrans.png");
system("cp semitrans.png /sites/TEST/tempgrid.png");
