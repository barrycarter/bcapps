#!/bin/perl

# http://www.srh.noaa.gov/gis/kml/ lists many KMZ files which actually
# contain current surface observations (in some cases, you have to
# follow links); this program downloads those surface observations and
# puts them in a db; it overrides most bc-get-[thing].pl programs in
# this directory

# TODO: cloudcover IS included in some reports! (but not "events")

require "/usr/local/lib/bclib.pl";
dodie("chdir('/var/tmp')");

# convert fields in KMZ files to weather2.sql format
%convert = ("TEMP" => "temperature", "DWPT" => "dewpoint",
	    "WIND DIR" => "winddir", "OBS TYPE" => "type");

@urls = ("http://www.srh.noaa.gov/gis/kml/raws/rawstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/aprswxnet/aprstf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/mesowest/mesowesttf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/other/othertf.kmz",
	 "http://www.srh.noaa.gov/gis/kml/metar/tf.kmz"
	 );

for $i (@urls) {
  # obtain file and unzip if needed
  $i=~/([^\/]*?)\.kmz$/;
  $file = $1;
  my($out,$err,$res) = cache_command2("curl -O $i","age=900");
  if ((-M "$file.kmz" < -M "$file.kml") || !(-f "$file.kml")) {
    system("unzip -jo $file.kmz; touch $file.kml");
  }

  my($data) = read_file("$file.kml");

  # parse data
  # TODO: should I dl all first then parse?

  # build hash from each placemark
  while ($data=~s%<placemark>(.*?)</placemark>%%is) {
    my($report) = $1;
    %dbhash = ();

    # ugly, but works
    $report=~s%<tr><td><B>ELEV</B>.*?<B>(\d+) FT</B>.*</td></tr>%%i;
    $dbhash{elevation} = $1;

    $report=~s%<tr><td><B>TEMP</B>.*?<B>(\d+) F</B>.*</td></tr>%%i;
    $dbhash{temperature} = $1;

    $report=~s%<tr><td><B>DEWP</B>.*?<B>(\d+) F</B>.*</td></tr>%%i;
    $dbhash{dewpoint} = $1;

    debug("DBHASH",%dbhash);
    die "TESTING";
    # snip out data
    %hash = ();
    # name and coords
    $report=~s%<name>(.*?)</name>%%;
    $hash{name} = $1;
    $report=~s%<coordinates>([\d\-\.]+?)\s*,\s*([\d\-\.]+).*</coordinates>%%;
    ($hash{longitude},$hash{latitude}) = ($1,$2);
    while ($report=~s%<tr><td><B>(.*?)</B></td><td><B>(.*?)</B></td>.*?</tr>%%) {
      if ($convert{$1}) {$hash{$convert{$1}} = $2} else {$hash{$1}=$2;}
    }

    # cleanup to insert in db
    %dbhash = ();
    # copy overs
    for $j ("latitude", "longitude", values %convert) {
      $dbhash{$j} = $hash{$j};
    }
    # trivial cleanup
    for $j ("dewpoint", "temperature") {$dbhash{$j}=~s/[cf\s]//isg;}

    # extract id from name
    $hash{name}=~s/^\s*(\S+)\s*//;
    $dbhash{id} = $1;
    $dbhash{name} = $hash{name};
    $dbhash{name}=~s/\s+/ /isg;

    $hash{"WIND SPD"}=~s/\s*kt\s*//isg;
    $dbhash{windspeed} = convert($hash{"WIND SPD"},"kt","mph");

    $hash{"WIND GUST"}=~s/\s*kt\s*//isg;
    $dbhash{gust} = convert($hash{"WIND GUST"},"kt","mph");

    $hash{ELEV} =~s/\s*m\s*//isg;
    $dbhash{elevation} = convert($hash{ELEV}, "m", "ft");

    # this is just to compare what I get here to what I get from other sources
    print "$dbhash{id} $dbhash{latitude} $dbhash{longitude} $dbhash{type}\n";

    for $j (sort keys %hash) {debug("HASH: $j -> $hash{$j}");}
    for $j (sort keys %dbhash) {debug("DBHASH: $j -> $dbhash{$j}");}

  }
}



=item convert_reading($val, $target_unit, $round)

For this program only, convert $val to $target_unit, rounding to
$round places, preserving nulls

=cut

sub convert_reading {
  my($val, $target_unit, $round);
  debug("VAL: $val");
}

