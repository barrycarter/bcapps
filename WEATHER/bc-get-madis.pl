#!/bin/perl

# http://www.srh.noaa.gov/gis/kml/ lists many KMZ files which actually
# contain current surface observations (in some cases, you have to
# follow links); this program downloads those surface observations and
# writes queries to put them into madis.db

require "/usr/local/lib/bclib.pl";
dodie("chdir('/var/tmp')");

# obtain METAR data for later use
@minfo = sqlite3hashlist("SELECT * FROM stations","/sites/DB/stations.db");

# TODO: this program is getting very cluttered, break this out?
for $i (@minfo) {
  # create hash mapping code to data
  $minfo{$i->{metar}} = $i;
}

@urls = ("http://www.srh.noaa.gov/gis/kml/metar/tf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/raws/rawstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/aprswxnet/aprstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/mesowest/mesowesttf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/other/othertf.kmz",
	 "http://wdssii.nssl.noaa.gov/realtime/metar/recent/METAR.kmz"
	 );

my(@reports);
for $i (@urls) {
  # obtain file and unzip if needed
  $i=~/([^\/]*?)\.kmz$/;
  $file = $1;
  # TODO: age=900 bad for 10m METAR reports?
  # TODO: METAR reports in METAR.kmz should override others (which
  # they do since its last, but that seems dicey)
  my($out,$err,$res) = cache_command2("curl -O $i","age=300");

  # if the KML file exists and is younger than the KMZ file, nothing to do
  if (-f "$file.kml" && (-M "$file.kml" < -M "$file.kmz")) {next;}

  # KMZ file is younger, so update KML file, read it, strip nulls
  system("unzip -c $file.kmz > $file.kml");
  my($data) = read_file("$file.kml");
  $data=~s/\0//isg;

  # parse data
  # TODO: should I dl all first then parse?

  # build hash from each placemark
  while ($data=~s%<placemark>(.*?)</placemark>%%is) {
    my($report) = $1;
    # remove deadly quotation marks
    # <h>it sometimes bugs me that I use isg even for non-alpha chars</h>
    $report=~s/\"//isg;
    %dbhash = ();
    # full observation not given (except for METAR)
    $dbhash{observation} = "(from KML file)";

    # source data
    $dbhash{source} = "$i";

    # report_tag:unit:db field
    for $j ("ELEV:FT:elevation", "TEMP:F:temperature", "DWPT:F:dewpoint",
	    "WIND SPD:MPH:windspeed", "WIND GUST:MPH:gust", 
	    "WIND DIR::winddir", "OBS TYPE::type", "OBS DATE/TIME::time",
	    "ALT SETTING:IN HG:pressure", "PRES WX::events",
	    "SKY::cloudcover") {
      my($f1,$unit,$f2) = split(":",$j);
      if ($report=~s%<tr><td><B>$f1</B>.*<B>(.*?)\s*$unit</B>.*</td></tr>%%im){
	$dbhash{$f2} = $1;
      } else {
	$dbhash{$f2} = "NULL";
      }
    }

    # special cases
    if ($report=~s%<coordinates>(.*?),\s*(.*?),\s*.*?</coordinates>%%im) {
      ($dbhash{longitude}, $dbhash{latitude}) = ($1,$2);
    } else {
      warn("NO COORDS?: $report");
    }

    # switch between METAR.kmz and other files
    # TODO: this could actually be a check on the filename instead of
    # convoluted test below
    if ($report=~s%<name>(.{5}\d{6}Z.*)</name>%%) {
      # don't wipe out existing entries (eg, lat/lon), just add
      %dbhash2 = parse_metar($1);
      unless ($minfo{$dbhash2{id}}) {
	warn "UNKNOWN METAR: $dbhash2{id}";
      }
      $dbhash{elevation} = $minfo{$dbhash2{id}}{elevation};
      $dbhash{name} = "$minfo{$dbhash2{id}}{city}, $minfo{$dbhash2{id}}{state}, $minfo{$dbhash2{id}}{country}";
      debug("DIFFS",$minfo{$dbhash2{id}}{latitude}-$dbhash{latitude});
      debug("THIS IS METAR");
      for $j (keys %dbhash2) {$dbhash{$j} = $dbhash2{$j};}
      $dbhash{type} = "METAR-10M";
    } elsif ($report=~s%<name>(.*?)\s+(.*)</name>%%) {
      ($dbhash{id}, $dbhash{name}) = ($1,$2);
    } else {
      warn("NO NAME?: $report");
    }

    # repeated latlons = bad
    if ($latlonseen{$dbhash{longitude}}{$dbhash{latitude}}) {
      warn("LATLON FOR $dbhash{id} ($dbhash{longitude},$dbhash{latitude}) SEEN BEFORE: $latlonseen{$dbhash{longitude}{$dbhash{latitude}}}");
    }

    debug("ALPHA: $dbhash{longitude} $dbhash{latitude} -> $dbhash{id}");
    $latlonseen{$dbhash{longitude}{$dbhash{latitude}}} = $dbhash{id};

    # cleanup
    $dbhash{name}=~s/\s+/ /isg;
    # if no name at all, use id
    unless ($dbhash{name}) {$dbhash{name} = $dbhash{id};}
    # making time format agree with sqlite3 TIMESTAMP/DATETIME format
    $dbhash{time} = strftime("%Y-%m-%d %H:%M:%S",gmtime(str2time("$dbhash{time} UTC")));

    debug("DBHASH",%dbhash);
    push(@reports, {%dbhash});

  }
}

my(@querys) = hashlist2sqlite(\@reports, "madis");

my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-madis-$$";
open(A,">$qfile");
print A "BEGIN;\n";

for $i (@querys) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
}

print A "COMMIT;\n";

# delete old reports + clean db
# print A "DELETE FROM madis_now WHERE MIN(time,timestamp) < DATETIME(CURRENT_TIMESTAMP, '-3 hour');\n";
print A "DELETE FROM madis WHERE MIN(time,timestamp) < DATETIME(CURRENT_TIMESTAMP, '-24 hour');\n";

# let METAR-10M trump ASOS
# <h>the fact that this works proves sqlite3 > mysql</h>
# print A "DELETE FROM madis WHERE rowid IN (
# SELECT m1.rowid FROM madis m1 JOIN madis m2 ON (m1.type='ASOS'
# AND m2.type='METAR-10M' AND m1.id = m2.id AND m1.time = m2.time)
# );\n";

# print A "DELETE FROM madis_now WHERE rowid IN (
# SELECT m1.rowid FROM madis_now m1 JOIN madis_now m2 ON (m1.type='ASOS'
# AND m2.type='METAR-10M' AND m1.id = m2.id AND m1.time = m2.time)
# );\n";

# VACUUM now handled by query gobbler
# print A "VACUUM;\n";

close(A);
