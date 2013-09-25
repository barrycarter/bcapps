#!/bin/perl

# obtains the CONUS radar images (base reflectivity only) from
# http://radar.weather.gov/ridge/Conus/RadarImg/
# these are less accurate (lower resolution) and updated only once
# every 10m or so, but cover the entire country

# --nodaemon: don't "daemonize", end up after one run

# TODO: get regionals instead, google maps doesn't handle this one
# large image well

require "/usr/local/lib/bclib.pl";

die "This program has been subsumed by bc-get-radar.pl";

dodie('chdir("/var/tmp/radar")');

# this changes constantly
my($out,$err,$res) = cache_command2("curl http://radar.weather.gov/ridge/Conus/RadarImg/");
while ($out=~s%<a href="(Conus.*?\.gif)">%%is) {push(@imgs,$1);}
# most recent first and only get most recent working image
# TODO: maybe get them all since so few of them
@imgs = reverse(sort(@imgs));
# most recent file for which we have a valid image
my($mrf);

for $i (@imgs) {
  $mrf = $i;
  # if I have the image (and its not the deadly 4618 bytes in size), move on
  if (-f $i && -s $i > 4618) {last;}
  # get the image
  ($out,$err,$res) = cache_command2("curl -O http://radar.weather.gov/ridge/Conus/RadarImg/$i");
  if (-s $i > 4618) {last;}
  debug("$i too small, going with next file");
}

# convert most recent file ($mrf) to semi-transparent and copy to site
system("convert /var/tmp/radar/$mrf -transparent white -channel Alpha -evaluate Divide 2 /var/tmp/radar/$mrf.png");
system("cp $mrf.png /sites/data/");

# the gfw (almost never changes)
($out,$err,$res) = cache_command2("curl -O http://radar.weather.gov/ridge/Conus/RadarImg/latest_radaronly.gfw", "age=86400");

# parse gfw and create KML file
my($xp, $r1, $r2, $yp, $xc, $yc) = split(/\r\n/, read_file("latest_radaronly.gfw"));

# assuming file is 3400x1600 though this may change one day
my($sc) = $yc+$yp*1600;
my($ec) = $xc+$xp*3400;
debug("SC/EC: $sc,$ec");

# find the center point to placemark date of file
my($cx,$cy) = (($ec+$xc)/2, ($sc+$yc)/2);

    # create KML file
my($str) = << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
<GroundOverlay>
<Description>$mrf</Description>
<Icon>
<href>http://data.bcinfo3.barrycarter.info/$mrf.png</href>
</Icon>
<LatLonBox>
<north>$yc</north>
<south>$sc</south>
<east>$ec</east>
<west>$xc</west>
</LatLonBox>
</GroundOverlay>
<ScreenOverlay>
<Icon>
<href>http://data.bcinfo3.barrycarter.info/radar_key.png</href>
</Icon>
<overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>
<screenXY x="0" y="0" xunits="fraction" yunits="fraction"/>
</ScreenOverlay>
<Placemark><name>$mrf</name><Point><coordinates>
$cx,$cy
</coordinates></Point></Placemark>
</Document>
</kml>
MARK
;

write_file($str,"/sites/data/conus.kml");

if ($globopts{nodaemon}) {exit(0);}
sleep(60);
exec($0);


debug("MRF: $mrf");
die "TESTING";

my($out,$err,$res);
my(@overlays);

# TODO: get list below from main site, now hardcoded
 for $i ("N0R","N0S","N0V","N0Z","N1P","NCR","NET","NTP","NVL") {
  # obtain list of sites for this type of radar (changes rarely)
  my(@sites) = ();

  for $site (@sites) {
    # gets rid of garbage (but maybe assumes too much)
    unless ($site=~/^[A-Z]{3}$/) {next;}
    # radar is updated every 3m, so 90s is a good cache time

    # debugging: some files are listed in .out but vanish quickly
    write_file($out, "$i-$site.out");

    # list of files for this type of radar
    my(@files) = ();

    # look for hrefs
    while ($out=~s/<a href="(.*?)"//s) {
      my($href) = $1;
      unless ($href=~/^$site/) {next;}
      push(@files,$href);
      # if we already have this file, ignore
#      if (-f "/var/tmp/radar/$href") {next;}
      # obtain image
#      system("curl -O http://radar.weather.gov/ridge/RadarImg/$i/$site/$href");
      # convert to semi-transparent
      # TODO: move these to correct location!
#      system("convert /var/tmp/radar/$href -transparent white -channel Alpha -evaluate Divide 2 /var/tmp/radar/$href.png");
    }

    # no files? no hope
    unless (@files) {next;}

    # go through @files in reverse order, keeping first image that
    # actually exists (sometimes, pages above list images that don't
    # actually exist yet, grumble!)
    @files = reverse(sort(@files));
    debug("FILES",@files);
    # most mrf = most recent file
    my($mrf);

    for $j (@files) {
      $mrf = $j;
      debug("J: $j");
      # can't actually cache here: if this file doesn't exist one
      # time, it may exist next time
      ($out,$err,$res) = cache_command2("curl -O http://radar.weather.gov/ridge/RadarImg/$i/$site/$j");
      # sadly, $err does NOT tell if I got a 404, but size of 330 bytes does
      if (-s $j > 331) {last;}
      debug("$j too small, trying again");
    }

    # convert mrf to semi-transparent
    system("convert /var/tmp/radar/$mrf -transparent white -channel Alpha -evaluate Divide 2 /var/tmp/radar/$mrf.png");
    debug("MRF: $mrf");

    # copy this file (transparent version) to /sites/data
    system("cp $mrf.png /sites/data/${site}_$i.png");

    # these files almost never change...


    # from http://forecast.weather.gov/jetstream/doppler/gis.htm
    my($xp, $r1, $r2, $yp, $xc, $yc) = split(/\r\n/, $out);
    # assuming 600x550
    my($sc) = $yc+$yp*550;
    my($ec) = $xc+$xp*600;

    # find the center point to placemark date this file was created
    my($cx,$cy) = (($ec+$xc)/2, ($sc+$yc)/2);
    my($time) = strftime("%Y-%m-%d %H:%M:%S", gmtime(time()));

    # create ground overlay for this radar
    # create KML file
    my($str) = << "MARK";
<GroundOverlay>
<Description>$mrf</Description>
<Icon>
<href>http://data.bcinfo3.barrycarter.info/${site}_$i.png</href>
</Icon>
<LatLonBox>
<north>$yc</north>
<south>$sc</south>
<east>$ec</east>
<west>$xc</west>
</LatLonBox>
</GroundOverlay>
<Placemark><name>$mrf</name><Point><coordinates>
$cx,$cy
</coordinates></Point></Placemark>
MARK
;
  push(@overlays, $str);
}

$overlays = join("\n",@overlays);

# create KML file
  $str = << "MARK";
$overlays
MARK
;
  
write_file($str,"/sites/data/radar_$i.kml");
}

# TODO: combine radar images into one file, naturally

if ($globopts{nodaemon}) {exit(0);}
sleep(60);
exec($0);
