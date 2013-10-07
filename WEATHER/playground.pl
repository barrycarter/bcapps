#!/usr/bin/perl

require "/usr/local/lib/bclib.pl";

debug(get_raws_obs());

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
    # then id, elev, lat, lon (elev is in ft!)
    my($lat,$lon);
    ($hash{id},$hash{elev},$lat,$lon) = split(/\s+/, $meta);
    # correct lat/lon
    unless ($lat=~m/^(\d+):(\d+):(\d+)$/) {warn "BAD LAT: $lat";}
    $hash{latitude} = $1+$2/60+$3/3600;

    unless ($lon=~m/^(\d+):(\d+):(\d+)$/) {warn "BAD LON: $lon";}
    # all longitudes are negative
    $hash{longitude} = -1*($1+$2/60+$3/3600);

    # of what remains first line is now current data
    $data=~s/\n.*$//isg;
    # fields we want start at col 25
    my(@data) = split(/[\s\/]+/, substr($data,25));
    debug("STAT: $i, DATA",@data);
#    debug("$day, $time, $hash{temperature}, $hash{dewpoint}, $wind, $gust");
    # rest don't have spaces, so...
    my($day, $time, $temp, $dew, $wind) = ();

  }
}

