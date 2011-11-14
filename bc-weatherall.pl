#!/bin/perl

# Gave up on learning python (whitespace is significant? blech!), and
# porting bc-excuse-to-learn.py to Perl: this attempts to perform all
# weather functions that other programs have done individually: create
# Voronoi and Delauney maps for multiple data, download latest data,
# maintain db, etc. Once complete, this program will replace many others

# Program attempts to be efficient by using GNU parallel as much as possible

# --nocurl: don't run curl if metar.txt and buoy.txt already exist

require "bclib.pl";

# fixed temporary directory
dodie('chdir("/tmp/bcweatherall")');

# get the METAR and BUOY files in parallel
unless (-f "metar.txt" && -f "buoy.txt" && $globopts{nocurl}) {
  write_file("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6 > metar.txt
curl -o buoy.txt http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt
", "commands");
  system("parallel -j 0 < commands");
}

# METAR file
@metar = split(/\n/, read_file("metar.txt"));
$headers = shift(@metar);

# sky_cover and cloud_base_ft_agl appear >=2 times, but I don't need the latter
$headers=~s/,sky_cover,/",sky_cover" . $n++ .","/iseg;
@headers = csv($headers);

for $i (@metar) {
  @fields = csv($i);
  %hash = ();
  for $j (0..$#headers) {
    debug("$headers[$j] -> $fields[$j], $j");
    $hash{$headers[$j]} = $fields[$j];
  }
  die "TESTING";
  push(@metarhashes, {%hash});
}

debug(unfold(@metarhashes));



