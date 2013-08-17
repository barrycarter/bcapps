#!/bin/perl

# obtains radar images for Albuquerque and transparent-izes them

require "/usr/local/lib/bclib.pl";

for $i ("N0R","N0S","N0V","N0Z","N1P","NCR","NET","NTP","NVL") {
  my($url) = "http://radar.weather.gov/ridge/RadarImg/$i/ABX_${i}_0.gif";
  # radar is updated every 3m, so 90s is a good cache time
  # cache_command2 doesn't support retfile yet
  my($out) = cache_command("curl $url","age=90&retfile=1");
  # convert to half-transparent png
  system("convert $out -channel Alpha -evaluate Divide 2 /var/tmp/ABX_$i.png");

  # create KML file (the box is hardcoded for Albuquerque; in theory,
  # could use GFX files to determine bounding box)
  $str = << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
<GroundOverlay>
<Icon>
<href>http://data.bcinfo3.barrycarter.info/ABX_$i.png</href>
</Icon>
<LatLonBox>
<north>37.5650361494585</north>
<south>32.726168961958</south>
<east>-104.17921697443</east>
<west>-109.457981178977</west>
</LatLonBox>
</GroundOverlay>
</Document>
</kml>
MARK
;
  write_file($str,"/var/tmp/ABX_$i.kml");
}
