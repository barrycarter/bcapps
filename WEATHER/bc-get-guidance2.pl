#!/bin/perl

# rewrite of bc-get-guidance.pl to be more like bc-get-metar.db

require "/usr/local/lib/bclib.pl";

# load METAR data from stations.db
@res1 = sqlite3hashlist("SELECT * FROM stations","/sites/DB/stations.db");
for $i (@res1) {$statinfo{$i->{metar}} = $i;}

my($url) = "http://nws.noaa.gov/mdl/forecast/text/avnmav.txt";
my($out,$err,$res) = cache_command2("curl $url", "age=3600");

# store results
write_file($out, "/var/tmp/mos-guidance.txt");

my(%convert) = ("TMP" => "temperature", "DPT" => "dewpoint", 
		"WDR" => "winddir", "WSP" => "windspeed", 
		"CLD" => "cloudcover");

for $i (split(/\n\s*\n/, $out)) {
  # first row has station time/date (add colon for str2time)
  $i=~s/^\s*(.*?)\s+GFS MOS GUIDANCE\s+(.*?)\s+(\d\d)(.*? UTC)//;
  my($stat,$date,$time,$inithour) = ($1, $2, "$3:$4",$3);
  my($start) = str2time("$date $time");

  # handle rows
  my(%hash) = ();

  # hash for rows
    my(%hash) = ();
    while ($i=~s/^\s*(\S+)\s*(.*?)$//m) {
      my($key,$vals) = ($1,$2);
      # we need a leading space
      $vals = " $vals";
      # 3 characters at a time...
      while ($vals=~s/(...)//) {
	my($val) = $1;
	# 99 is null for WDR/WSP
	if ($val == "99" && ($key eq "WDR" || $key eq "WSP")) {$val="NULL";}
	# otherwise, 999 is null
	if ($val == "999") {$val = "NULL";}
	push(@{$hash{$key}}, trim($val));
      }
    }

  # iterate along the hours
  my(%rethash) = ();
  for $j (0..$#{$hash{HR}}) {
    # figure out ISO hour by looking at gap
    my($gap);
    if ($j==0) {
      $gap = $hash{HR}[0] - $inithour;
    } else {
      $gap = $hash{HR}[$j] - $hash{HR}[$j-1];
    }

    if ($gap<0) {$gap+=24;}
    $start += $gap*3600;

    # build the hash for this station/time
    $rethash{$stat}{$start}{observation} = "(from guidance file)";
    $rethash{$stat}{$start}{type} = "MOS";
    $rethash{$stat}{$start}{id} =  $stat;
    $rethash{$stat}{$start}{time} = strftime("%Y-%m-%d %H:%M:%S",gmtime($start));

    # some fixed quantities
    $rethash{$stat}{$start}{source} = "http://nws.noaa.gov/mdl/forecast/text/avnmav.txt";

    $rethash{$stat}{$start}{name} = "$statinfo{$stat}{city}, $statinfo{$stat}{state}, $statinfo{$stat}{country}";
    $rethash{$stat}{$start}{name}=~s/\s*,\s*,\s*/, /isg;
    $rethash{$stat}{$start}{name}=~s/\s*,\s*/, /isg;

    for $k ("gust", "events", "pressure") {
      $rethash{$stat}{$start}{$k}="NULL";
    }

    for $k ("latitude", "longitude", "elevation") {
      $rethash{$stat}{$start}{$k} = $statinfo{$stat}{$k};
    }

    # and now the data
    for $k (keys %convert) {
      $rethash{$stat}{$start}{$convert{$k}} = @{$hash{$k}}[$j];
    }

    # except for this, data is already in correct units
    $rethash{$stat}{$start}{winddir}*=10;

    # need to declare a hash here solely so I have ref to it
    my(%rhash) = %{$rethash{$stat}{$start}};
    push(@res, {%rhash});
  }
}

@queries = hashlist2sqlite(\@res, "madis");
my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-guidance-$$";
open(A,">$qfile");
print A "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
}

print A "COMMIT;\n";
close(A);
