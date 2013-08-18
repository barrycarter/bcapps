#!/bin/perl

# obtains radar images for Albuquerque and transparent-izes them

require "/usr/local/lib/bclib.pl";

$site = "ABX";

for $i ("N0R","N0S","N0V","N0Z","N1P","NCR","NET","NTP","NVL") {
  # this one is current even when timestamp looks odd
  my($url) = "http://radar.weather.gov/ridge/RadarImg/$i/${site}_${i}_0.gif";

  # radar is updated every 3m, so 90s is a good cache time
  # cache_command2 doesn't support retfile yet
  my($out) = cache_command("curl $url","age=90&retfile=1");
  debug("$url -> $out");

  # convert to half-transparent png
  system("convert $out -transparent white -channel Alpha -evaluate Divide 2 /sites/data/${site}_$i.png");

  # these files almost never change...
  ($out,$err,$res) = cache_command2("curl http://radar.weather.gov/ridge/RadarImg/$i/${site}_${i}_0.gfw", "age=86400");

  # from http://forecast.weather.gov/jetstream/doppler/gis.htm
  my($xp, $r1, $r2, $yp, $xc, $yc) = split(/\r\n/, $out);
  # assuming 600x550
  my($sc) = $yc+$yp*550;
  my($ec) = $xc+$xp*600;
  debug("$xc/$ec");
  # create KML file (the box is hardcoded for Albuquerque; in theory,
  # could use GFX files to determine bounding box)
  $str = << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
<GroundOverlay>
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
</Document>
</kml>
MARK
;
  write_file($str,"/sites/data/${site}_$i.kml");
}

sleep(60);
exec($0);
