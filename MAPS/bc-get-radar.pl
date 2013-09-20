#!/bin/perl

# obtains radar images for Albuquerque and transparent-izes them
# --nodaemon: don't "daemonize", end up after one run

# NOTE: there are about 219 radar stations listed by radar.weather.gov
# This version does NOT create KML files

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/radar")');

@sites = ("ABX");
@types = ("N0R","NCR","N0Z", "N0S", "N0V", "N1P", "NTP");

# could make $i and $j args and parallelize that way?
for $i (@sites) {
  for $j (@types) {
    # get the radar image
    my($res) = get_current_radar($i,$j);
    # if we already have the .png version, nothing else to do
    if (-f "$res.png") {next;}
    # if not, comment it, semi-transparentize it
    system("convert -comment '$res' $res -transparent white -channel Alpha -evaluate Divide 2 $res.png");
    # and copy it to latest (and also put copy in /sites/db)
    system("cp $res.png /sites/data/; cp $res.png /sites/data/$i-$j.png");
  }
}

if ($globopts{nodaemon}) {exit(0);}
sleep(60);
exec($0);

=item get_current_radar($station,$type)

Obtain the current $type radar for $station and put it in
/var/tmp/radar. Return the filename (which also contains the
timestamp)

If latest radar is in /var/tmp/radar, just return filename

=cut

sub get_current_radar {
  my($station,$type) = @_;

  # obtain site index (upto 1m old)
  # TODO: putting this in file (for debugging) is ugly
  # TODO: allow parallelizing this, one at a time may be too slow
  my($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/$station-$type.out http://radar.weather.gov/ridge/RadarImg/$type/$station/","age=60");
  $out = read_file("/var/tmp/radar/$station-$type.out");

  # look for hrefs sort by time reversed
  my(@files) = reverse(sort($out=~m/<a href="($station.*?)"/sg));

  # attempt to get most current
  for $i (@files) {
    # if we already have this one and its over the dreaded 331 bytes, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
    # we don't have it, so try to get it
    ($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/$i http://radar.weather.gov/ridge/RadarImg/$type/$station/$i");
    # if we have it now, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
  }

  # this means we didnt get it at all!
  return;
}
