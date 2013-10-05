#!/usr/bin/perl

require "/usr/local/lib/bclib.pl";

@l = recent_forecast2();

debug(var_dump("l",[@l]));

sub recent_forecast2 {
  # TODO: cleanup vars I no longer use
  my($options) = ();
  my($cur,$date,$time,$unix);
  my(@hrs,@realhours);
  my(%rethash);

  # this is probably a bad way to do this (global %stathash)
  unless (%stathash) {
    # TODO: subroutinize this?
    for $i (split(/\n/,read_file("/home/barrycarter/BCGIT/WEATHER/juststations.txt"))) {
      $i=~/^(\S+)\s+(.{28})\s*(\S+)\s*(\S+)$/;
      my($stat,$name,$lat,$long) = ($1,$2,$3,$4);
      # cleanup
      $name=~s/\s+/ /isg;
      $name=trim($name);
      # most/all are in NW quadrant of globe, but...
      if ($lat=~s/S$//) {$lat*=-1;} else {$lat=~s/N$//;}
      if ($long=~s/W$//) {$long*=-1;} else {$long=~s/E$//;}
      $stathash{$stat}{name} = $name;
      $stathash{$stat}{longitude} = $long;
      $stathash{$stat}{latitude} = $lat;
    }
  }

  # TODO: consider using other data MOS provides (esp N/X X/N)

  # convert MOS guidance headers to weather2.sql headers
  # cloudcover not given for all reports; also, I haven't settled on
  # consistent format
  my(%convert) = ("TMP" => "temperature", "DPT" => "dewpoint", 
		  "WDR" => "winddir", "WSP" => "windspeed", 
		  "CLD" => "cloudcover");

  # guidances are for 6h, so 1h cache is fine; and store since its important
  my($out,$err,$res) = cache_command2("curl -o /var/tmp/mos-guidance.txt http://nws.noaa.gov/mdl/forecast/text/avnmav.txt", "age=3600");
  my($all) = read_file("/var/tmp/mos-guidance.txt");

  for $i (split(/\n\s*\n/, $all)) {
    # first row has station time/date (add colon for str2time)
    $i=~s/^\s*(.*?)\s+GFS MOS GUIDANCE\s+(.*?)\s+(\d\d)(.*? UTC)//;
    my($stat,$date,$time,$inithour) = ($1, $2, "$3:$4",$3);
    my($start) = str2time("$date $time");

    # hash for rows
    my(%hash) = ();
    while ($i=~s/^\s*(\S+)\s*(.*?)$//m) {
      @{$hash{$1}} = split(/\s+/, $2);
    }

    # TODO: error check (eg, "999")
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
      $rethash{$stat}{$start}{type} = "MOS";
      $rethash{$stat}{$start}{id} =  $stat;
      $rethash{$stat}{$start}{time} = strftime("%Y-%m-%d %H:%M:%S",gmtime($start));
      for $k ("name", "latitude", "longitude") {
	$rethash{$stat}{$start}{$k} = $stathash{$stat}{$k};
      }

      # and now the data
      for $k (keys %convert) {
	$rethash{$stat}{$start}{$convert{$k}} = @{$hash{$k}}[$j];
      }

      # except for this, data is already in correct units
      $rethash{$stat}{$start}{winddir}*=10;

      # TODO: add elevation from mos-guidance.html file (do we have this?)
    }
    push(@res, {%rethash});
  }
  return @res;
}

die "TESTING";

# tests by recreating
chdir("/home/barrycarter/BCGIT/WEATHER");
system("rm /tmp/test.db; sqlite3 /tmp/test.db < weather2.sql; ./bc-get-metar.pl | sqlite3 /tmp/test.db; ./bc-get-ship.pl | sqlite3 /tmp/test.db; ./bc-get-buoy.pl | sqlite3 /tmp/test.db");

die "TESTING";

get_raws_obs();

=item get_raws_obs()

Obtain weather information from http://raws.wrh.noaa.gov/rawsobs.html

/var/tmp/raws must exist and be write-able

=cut

sub get_raws_obs {
  # chdir to correct directory
  dodie('chdir("/var/tmp/raws")');
  # index page almost never changes
  my($out,$err,$res) = cache_command2("curl http://raws.wrh.noaa.gov/rawsobs.html", "age=86400");
  # use parallel
  local(*A);
  open(A, "| parallel -j 10");
  my(@stns);

  # find hrefs and push to "well known" files
  while ($out=~s%"(http://raws.wrh.noaa.gov/.*?)"%%s) {
    my($url) = $1;
    unless ($url=~/stn\=(.*)/s) {next;}
    my($stn) = $1;
    push(@stns,$stn);
    # if we have a file less than an hour old, do nothing
    if (-f $stn && -M $stn < 1/24.) {next;}
    print A "curl -o $stn '$url'\n";
  }
  close(A);

  # now look thru data
  for $i (@stns) {
    my($data) = read_file($i);
    # get lat/lon/name/id
    $data=~s/\={20,}\s*(.*?)(\r|\n)+.*\={20,}\s+//s;
    my($meta) = $1;
    # first 22 chars are name
    $meta=~s/^(.{22})//;
    my($name) = $1;
    # rest don't have spaces, so...
    my($day, $time, $temp, $dew, $wind) = 

    debug("NAME: $name");
  }
}

