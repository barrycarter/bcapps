#!/bin/perl

# http://www.srh.noaa.gov/gis/kml/ lists many KMZ files which actually
# contain current surface observations (in some cases, you have to
# follow links); this program downloads those surface observations and
# puts them in a db; it overrides most bc-get-[thing].pl programs in
# this directory

# --nodaemon: just run once, don't "daemonize"

require "/usr/local/lib/bclib.pl";
dodie("chdir('/var/tmp')");

@urls = ("http://www.srh.noaa.gov/gis/kml/metar/tf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/raws/rawstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/aprswxnet/aprstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/mesowest/mesowesttf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/other/othertf.kmz"
	 );

my(@reports);
for $i (@urls) {
  # obtain file and unzip if needed
  $i=~/([^\/]*?)\.kmz$/;
  $file = $1;
  my($out,$err,$res) = cache_command2("curl -O $i","age=900");
  if ((-M "$file.kmz" < -M "$file.kml") || !(-f "$file.kml")) {
    debug("$file.kmz is younger than $file.kml");
    system("unzip -jo $file.kmz; touch $file.kml");
  }

  my($data) = read_file("$file.kml");
  # parse data
  # TODO: should I dl all first then parse?

  # build hash from each placemark
  while ($data=~s%<placemark>(.*?)</placemark>%%is) {
    my($report) = $1;
    # remove deadly quotation marks
    # <h>it sometimes bugs me that I use isg even for non-alpha chars</h>
    $report=~s/\"//isg;
    %dbhash = ();

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
    if ($report=~s%<coordinates>(.*?), (.*?), .*?</coordinates>%%im) {
      ($dbhash{longitude}, $dbhash{latitude}) = ($1,$2)
    } else {
      die "NO COORDS?: $report";
    }

    if ($report=~s%<name>(.*?)\s+(.*)</name>%%) {
      ($dbhash{id}, $dbhash{name}) = ($1,$2);
    } else {
      die "NO NAME?: $report";
    }

    # cleanup
    $dbhash{name}=~s/\s+/ /isg;
    # if no name at all, use id
    unless ($dbhash{name}) {$dbhash{name} = $dbhash{id};}
    $dbhash{time} = strftime("%Y-%m-%dT%H:%MZ",gmtime(str2time("$dbhash{time} UTC")));

    push(@reports, {%dbhash});

  }
}

my(@querys) = hashlist2sqlite(\@reports, "madis");

open(A,">queries.txt");
print A "BEGIN;\n";

for $i (@querys) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
  # and now for weather_now
  $i=~s/madis/madis_now/;
  print A "$i;\n";
}

print A "COMMIT;\n";
close(A);

# TODO: shouldn't tweak db in place?
system("sqlite3 /sites/DB/madis.db < queries.txt");

in_you_endo();
unless ($globopts{nodaemon}) {
  sleep(60);
  exec($0);
}

