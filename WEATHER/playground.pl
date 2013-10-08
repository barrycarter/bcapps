#!/usr/bin/perl -w

require "/usr/local/lib/bclib.pl";

@res = get_raws_obs();
debug("RES",@res);
debug(hashlist2sqlite(\@res, "madis"));

die "TESTING";

# tests by recreating
chdir("/home/barrycarter/BCGIT/WEATHER");
system("rm /tmp/test.db; sqlite3 /tmp/test.db < weather2.sql; ./bc-get-metar.pl | sqlite3 /tmp/test.db; ./bc-get-ship.pl | sqlite3 /tmp/test.db; ./bc-get-buoy.pl | sqlite3 /tmp/test.db");

die "TESTING";

get_raws_obs();

=item get_raws_obs()

Obtain weather information from http://raws.wrh.noaa.gov/rawsobs.html

NOTE: Temperatures are in Farenheit and wind speeds are in mph <h>also
known as the "good" or "correct" units</h>

RAWS does not provide: pressure <h>("you can not handle
PRESSURE!")</h>, cloudcover, events

TODO: maybe use solar radiation readings (could be used to determine
cloudcover maybe)

=cut

sub get_raws_obs {
  my(@res);
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
    my(%hash);
    my($data) = read_file($i);
    # get lat/lon/name/id
    $data=~s/^.*?\={20,}\s*(.*?)(\r|\n)+.*\={20,}\s+//s;
    my($meta) = $1;
    # if there is absolutely no data, no point in doing more
    unless ($data) {
      warn("$i: NO DATA");
      next;
    }

    # first 23 chars are name (w/ spaces)
    $meta=~s/^(.{23})//;
    $hash{name} = $1;
    $hash{name}=~s/\s*$//isg;
    # then id, elev, lat, lon (elev is in ft!)
    my($lat,$lon);
    ($hash{id},$hash{elevation},$lat,$lon) = split(/\s+/, $meta);
    # using more familiar id here, overriding above
    $hash{id} = $i;
    # correct lat/lon
    unless ($lat=~m/^(\d+):(\d+):(\d+)$/) {warn "BAD LAT: $lat";}
    $hash{latitude} = $1+$2/60+$3/3600;

    unless ($lon=~m/^(\d+):(\d+):(\d+)$/) {warn "BAD LON: $lon";}
    # all longitudes are negative
    $hash{longitude} = -1*($1+$2/60+$3/3600);

    # of what remains first line is now current data
    $data=~s/\n.*$//isg;
    $hash{observation} = $data;
    $hash{observation}=~s/\s+/ /isg;
    my(@data) = column_data($data, [25,28,33,39,43,48,67,74]);
    # remove spaces/slashes
    for $j (@data) {$j=~s/[\s\/]//isg;}
    my($day,$time,$jnk);
    ($day,$time,$hash{temperature},$hash{dewpoint},$wind,$jnk,$gust) = @data;

    # parse wind
    unless ($wind=~/^(..)(..)$/) {warn "BAD WIND: $wind";}
    $hash{winddir} = $1*10;
    $hash{windspeed} = $2;
    if ($gust=~/g(\d+)/) {$hash{gust} = $1;}

    # parse time and date (don't need 00 minute)
    $time=~/(\d{2})(\d{2})/||warn("BAD TIME: $time");
    my($hr,$mi) = ($1, $2);
    my($today) = strftime("%d", gmtime(time()));
    if ($day <= $today+1) {
      $hash{time} = strftime("%Y-%m-$day $hr:$mi:00", gmtime(time()));
    } else {
      my($year, $month) = split(/\-/, strftime("%Y-%m", gmtime(time())));
      $month--;
      if ($month < 0) {$year--; $month=12;}
      $hash{time} = "$year-$month-$day $hr:$mi:00";
    }

    # push to result
    push(@res, {%hash});
  }

  return @res;
}



