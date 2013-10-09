#!/bin/perl

# http://www.srh.noaa.gov/gis/kml/ lists many KMZ files which actually
# contain current surface observations (in some cases, you have to
# follow links); this program downloads those surface observations and
# puts them in a db; it overrides most bc-get-[thing].pl programs in
# this directory

# --nodaemon: just run once, don't "daemonize"

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
  if ((-M "$file.kmz" < -M "$file.kml") || !(-f "$file.kml")) {
    debug("$file.kmz is younger than $file.kml");
#    system("unzip -jo $file.kmz; touch $file.kml");
    system("unzip -c $file.kmz > $file.kml");
  }

  # TODO: does this mean I parse the same file twice? blech!
  my($data) = read_file("$file.kml");
  # some files have nulls in them for some bizarre reason
  $data=~s/\0//isg;
  debug("FILE: $file.kml");
  # parse data
  # TODO: should I dl all first then parse?

  # build hash from each placemark
  while ($data=~s%<placemark>(.*?)</placemark>%%is) {
    my($report) = $1;
    debug("REPORT: $report");
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
    if ($report=~s%<coordinates>(.*?),\s*(.*?),\s*.*?</coordinates>%%im) {
      ($dbhash{longitude}, $dbhash{latitude}) = ($1,$2)
    } else {
      die "NO COORDS?: $report";
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
      $dbhash{elevation} = convert($minfo{$dbhash2{id}}{elevation},"m","ft");
      $dbhash{name} = "$minfo{$dbhash2{id}}{city}, $minfo{$dbhash2{id}}{state}, $minfo{$dbhash2{id}}{country}";
      debug("THIS IS METAR");
      for $j (keys %dbhash2) {$dbhash{$j} = $dbhash2{$j};}
      $dbhash{type} = "METAR-10M";
    } elsif ($report=~s%<name>(.*?)\s+(.*)</name>%%) {
      ($dbhash{id}, $dbhash{name}) = ($1,$2);
    } else {
      die "NO NAME?: $report";
    }

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

# delete old reports + clean db
print A "DELETE FROM madis_now WHERE timestamp < DATETIME(CURRENT_TIMESTAMP, '-3 hour');\n";
print A "DELETE FROM madis WHERE timestamp < DATETIME(CURRENT_TIMESTAMP, '-24 hour');\n";

# let METAR-10M trump ASOS
# <h>the fact that this works proves sqlite3 > mysql</h>
print A "DELETE FROM madis WHERE rowid IN (
SELECT m1.rowid FROM madis m1 JOIN madis m2 ON (m1.type='ASOS'
AND m2.type='METAR-10M' AND m1.id = m2.id AND m1.time = m2.time)
);\n";

print A "DELETE FROM madis_now WHERE rowid IN (
SELECT m1.rowid FROM madis_now m1 JOIN madis_now m2 ON (m1.type='ASOS'
AND m2.type='METAR-10M' AND m1.id = m2.id AND m1.time = m2.time)
);\n";

print A "VACUUM;\n";

close(A);

# TODO: shouldn't tweak db in place?
system("cp /sites/DB/madis.db /sites/DB/madis.db.new");
system("sqlite3 /sites/DB/madis.db.new < queries.txt");
system("mv /sites/DB/madis.db /sites/DB/madis.db.old; mv /sites/DB/madis.db.new /sites/DB/madis.db");

in_you_endo();
unless ($globopts{nodaemon}) {
  sleep(60);
  exec($0);
}
