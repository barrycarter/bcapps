#!/bin/perl

# http://www.srh.noaa.gov/gis/kml/ lists many KMZ files which actually
# contain current surface observations (in some cases, you have to
# follow links); this program downloads those surface observations and
# puts them in a db; it overrides most bc-get-[thing].pl programs in
# this directory

# TODO: METAR is an ugly format, can not use as is

require "/usr/local/lib/bclib.pl";
dodie("chdir('/var/tmp')");

@urls = ("http://www.srh.noaa.gov/gis/kml/raws/rawstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/aprswxnet/aprstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/mesowest/mesowesttf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/other/othertf.kmz"
	 );

for $i (@urls) {
  my($out,$err,$res) = cache_command2("curl $i","age=900");

  # write to file (not sure why I need to strip newline from $out but I do)
  $out=~s/^\s+//isg;
  $i=~s/^.*\///;
  write_file($out, $i);

  # parse data
  # TODO: should I dl all first then parse?
  # TODO: this is ugly, should be better way to handle zipped file
  my($data) = join("",`zcat $i`);

  # build hash from each placemark
  while ($data=~s%<placemark>(.*?)</placemark>%%is) {
    my($report) = $1;
    # snip out data
    %hash = ();
    # name and coords
    $report=~s%<name>(.*?)</name>%%;
    $hash{name} = $1;

    while ($report=~s%<tr><td><B>(.*?)</B></td><td><B>(.*?)</B></td>.*?</tr>%%) {
      $hash{$1}=$2;
    }
    debug("REMAIN: $report");
  }
}




