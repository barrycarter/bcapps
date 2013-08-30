#!/bin/perl

# obtains radar images for Albuquerque and transparent-izes them
# --nodaemon: don't "daemonize", end up after one run

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/radar")');

$site = "ABX";

for $i ("N0R","N0S","N0V","N0Z","N1P","NCR","NET","NTP","NVL") {
  # radar is updated every 3m, so 90s is a good cache time
  my($out,$err,$res) = cache_command2("curl http://radar.weather.gov/ridge/RadarImg/$i/$site/","age=90");
  # debugging: some files are listed in .out but vanish quickly
  write_file($out, "$i-$site.out");

  # list of files for this type of radar
  my(@files);

  # look for hrefs
  while ($out=~s/<a href="(.*?)"//is) {
    # ignore hrefs that dont point to site radar
    my($href) = $1;
    unless ($href=~/^$site/) {next;}

    # create list of files (even ones we have) for sorting later
    push(@files,$href);

    # if we already have this file, ignore
    if (-f "/var/tmp/radar/$href") {next;}
    # obtain image
    system("curl -O http://radar.weather.gov/ridge/RadarImg/$i/$site/$href");
    # convert to semi-transparent
    # TODO: move these to correct location!
  system("convert /var/tmp/radar/$href -transparent white -channel Alpha -evaluate Divide 2 /var/tmp/radar/$href.png");
  }

  # find most recent file (max() won't work here, not numerical)
  @files = sort(@files);
  my($mrf) = $files[$#files];
  # copy this file (transparent version) to /sites/data
  system("cp $mrf.png /sites/data/${site}_$i.png");

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

  # create KML file
  $str = << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
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
</Document>
</kml>
MARK
;
  write_file($str,"/sites/data/${site}_$i.kml");
}

if ($globopts{nodaemon}) {exit(0);}
sleep(60);
exec($0);
