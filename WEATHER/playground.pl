#!/usr/bin/perl

require "/usr/local/lib/bclib.pl";

%hash = recent_forecast2();

debug(var_dump("hash",{%hash}));

sub recent_forecast2 {
  my($options) = ();
  my($cur,$date,$time,$unix);
  my(@hrs,@realhours);
  my(%rethash);

  # there does not appear to be a compressed form
  # guidances are for 6h, so 1h cache is fine
  my($out,$err,$res) = cache_command("curl http://nws.noaa.gov/mdl/forecast/text/avnmav.txt", "age=3600");

  # TODO: can X/N sometimes be N/X (and does it give order of high/low?)

  for $i (split(/\n/,$out)) {
    # multiple spaces only for formatting, so I dont need them
    # TODO: I might be wrong about this
    $i=~s/\s+/ /isg;
    # station name and date of "forecast"
    if ($i=~/^\s*(.*?) GFS MOS GUIDANCE (.*?) (.*? UTC)/) {
      # $cur needs to live outside this loop
      ($cur, $date, $time) = ($1,$2,$3);
      # add colon to time for str2time
      $time=~s/^(\d\d)/$1:/;
      $unix = str2time("$date $time");
      # now strip UTC
      $time=~s/\s*UTC//;
      $rethash{$cur}{date} = $date;
      $rethash{$cur}{time} = $time;
      next;
    }

    # list of guidance hours (this doesn't really change per station, but...)
    if ($i=~s/^\s*hr\s*//i) {
      @realhours = ();
      @hrs = split(/\s+/,$i);
      # the guidance time is a psuedo-entry
      unshift(@hrs, $time);
      for $j (1..$#hrs) {
	my($gap) = ($hrs[$j]-$hrs[$j-1])*3600;
	if ($gap<0) {$gap+=86400;}
	$unix += $gap;
	$realhours[$j-1] = gmtime($unix);
      }
      next;
    }

    # list of other hourly data
    if ($i=~s/^\s*(tmp|dpt|cld|wdr|wsp|poz|pos|typ)\s*//i) {
      my($elt) = $1;
      my(@vals) = split(/\s+/,$i);
      for $j (1..$#realhours) {
	$rethash{$cur}{$realhours[$j]}{$elt} = $vals[$j];}
      next;
    }

    # TODO: split and return as list? determine hi from lo?
    # TODO: deal w 999s here or elsewhere?
    if ($i=~m%^\s*(X/N|N/X) (.*?)$%) {
      $rethash{$cur}{dir} = $1;
      $rethash{$cur}{hilo} = $2;
      next;
    }
  }

  return %rethash;
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

