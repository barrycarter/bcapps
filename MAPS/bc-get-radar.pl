#!/bin/perl

# obtains radar images for Albuquerque and transparent-izes them
# --nodaemon: don't "daemonize", end up after one run

# NOTE: there are about 219 radar stations listed by radar.weather.gov

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/radar")');

debug(get_current_radar("ABX","N0R"));

die "TESTING";

my($out,$err,$res);
my(@overlays);

# these are the only "interesting" radars, to me at least
for $i ("N0R","NCR","N0Z", "N0S", "N0V", "N1P", "NTP") {
  # obtain list of sites for this type of radar (changes rarely)
  my(@sites) = ();
#  ($out,$err,$res) = cache_command2("curl http://radar.weather.gov/ridge/RadarImg/$i/","age=86400");
#  while ($out=~s%<a href="([^>]*?)/">%%is) {push(@sites,$1);}

  # getting data from all sites was too slow, reducing to ABX for now;
  # see bc-get-conus.pl for more
  @sites = ("ABX");

  for $site (@sites) {
    # gets rid of garbage (but maybe assumes too much)
    unless ($site=~/^[A-Z]{3}$/) {next;}
    # radar is updated every 3m, so 90s is a good cache time
    ($out,$err,$res) = cache_command2("curl http://radar.weather.gov/ridge/RadarImg/$i/$site/","age=90");
    # debugging: some files are listed in .out but vanish quickly
    write_file($out, "$i-$site.out");

    # list of files for this type of radar
    my(@files) = ();

    # look for hrefs
    while ($out=~s/<a href="(.*?)"//s) {
      my($href) = $1;
      unless ($href=~/^$site/) {next;}
      push(@files,$href);
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
      # if we already have image and its over 331b, use it
      if (-f $j && -s $j > 331) {last;}
      # can't actually cache here: if this file doesn't exist one
      # time, it may exist next time
      ($out,$err,$res) = cache_command2("curl -O http://radar.weather.gov/ridge/RadarImg/$i/$site/$j");
      # sadly, $err does NOT tell if I got a 404, but size of 330 bytes does
      if (-s $j > 331) {last;}
      debug("$j too small, trying again");
    }

    # convert mrf to semi-transparent + add comment giving date
    system("convert -comment '$mrf' $mrf -transparent white -channel Alpha -evaluate Divide 2 $mrf.png");
    debug("MRF: $mrf");

    # copy this file (transparent version) to /sites/data
    system("cp $mrf.png /sites/data/${site}_$i.png");
    # keep original in /sites/data too for viewing of previous
    system("cp $mrf.png /sites/data/");

    # these files almost never change...
    ($out,$err,$res) = cache_command2("curl http://radar.weather.gov/ridge/RadarImg/$i/${site}_${i}_0.gfw", "age=86400");

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
MARK
;
  push(@overlays, $str);
}

$overlays = join("\n",@overlays);

# create KML file
  $str = << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
$overlays
</Document>
</kml>
MARK
;
  
write_file($str,"/sites/data/radar_$i.kml");
}

# TODO: combine radar images into one file, naturally

if ($globopts{nodaemon}) {exit(0);}
sleep(60);
exec($0);

=item get_current_radar($station,$type)

Obtain the current $type radar for $station and put it in
/var/tmp/radar. Return the filename (which also contains the
timestamp)

If latest radar is in /var/tmp/radar, just return filename

=cut

sub get_current_radar {
  my($station,$type) = @_;

  # obtain site index (upto 1m old)
  # TODO: putting this in file (for debugging) is ugly
  # TODO: allow parallelizing this, one at a time may be too slow
  my($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/$station-$type.out http://radar.weather.gov/ridge/RadarImg/$type/$station/","age=60");
  $out = read_file("/var/tmp/radar/$station-$type.out");

  # look for hrefs sort by time reversed
  my(@files) = reverse(sort($out=~m/<a href="($station.*?)"/sg));

  # attempt to get most current
  for $i (@files) {
    # if we already have this one and its over the dreaded 331 bytes, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
    # we don't have it, so try to get it
    ($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/$i http://radar.weather.gov/ridge/RadarImg/$type/$station/$i");
    # if we have it now, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
  }

  # this means we didnt get it at all!
  return;
}

