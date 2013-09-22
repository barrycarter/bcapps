#!/bin/perl

# obtains radar images for Albuquerque and comments them with timestamp
# --nodaemon: don't "daemonize", end up after one run

# NOTE: there are about 219 radar stations listed by radar.weather.gov
# This version does NOT create KML files

# Turns out google maps lets you set opacity directly, no need to do it here

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/radar")');

# TODO: I could do this better
my($res) = get_current_conus();
# no result, go to regular radar
unless ($res) {goto RADAR;}
# already have it?
if (-f "/sites/data/$res") {goto RADAR;}
# if not, convert and copy (both as timestamp and current file)
system("convert -comment '$res' /sites/data/$res; cp /sites/data/$res /sites/data/Conus.gif");

# I still feel bad about using a goto; <h>is there a support group?</h>
RADAR:
@sites = ("ABX");
@types = ("N0R","NCR","N0Z", "N0S", "N0V", "N1P", "NTP");

# could make $i and $j args and parallelize that way?
for $i (@sites) {
  for $j (@types) {
    # make sure HTML file for this radar is there
    unless (-f "/home/barrycarter/BCGIT/BCINFO3/sites/data/radar/$i-$j.html") {
      my($link) = create_radar_link($i,$j);
      write_file("<a href='$link'>$i-$j</a>", "/home/barrycarter/BCGIT/BCINFO3/sites/data/radar/$i-$j.html");
    }

    # get the radar image
    my($res) = get_current_radar($i,$j);
    debug("IJRES: $i, $j, $res");
    # if no return value, move on
    unless ($res) {next;}
    # if we already have it in the target dir, nothing to do
    if (-f "/sites/data/$res") {next;}
    # if not, add comment and copy
    debug("ABOUT TO CONVERT");
    system("convert -comment '$res' $res /sites/data/$res; cp /sites/data/$res /sites/data/$i-$j.gif");
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
    debug("LOOKING FOR: $i");
    # if we already have this one and its over the dreaded 331 bytes, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
    # we don't have it, so try to get it
    ($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/$i http://radar.weather.gov/ridge/RadarImg/$type/$station/$i");
    debug("/var/tmp/radar/$i hopefully written");
    # if we have it now, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
  }

  # this means we didnt get it at all!
  return;
}

=item get_current_conus()

Does what get_current_radar() does, but for Conus.
TODO: could probably merge this into get_current_radar()

=cut

sub get_current_conus {

  # obtain site index (upto 1m old)
  # TODO: putting this in file (for debugging) is ugly
  # TODO: allow parallelizing this, one at a time may be too slow
  my($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/conus.out http://radar.weather.gov/ridge/Conus/RadarImg/", "age=60");
  $out = read_file("/var/tmp/radar/conus.out");

  # look for hrefs sort by time reversed
  my(@files) = reverse(sort($out=~m/<a href="(Conus.*?)"/sg));

  # attempt to get most current
  for $i (@files) {
    # if we already have this one and its over the dreaded 331 bytes, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
    # we don't have it, so try to get it
    ($out,$err,$res) = cache_command2("curl -o /var/tmp/radar/$i http://radar.weather.gov/ridge/Conus/RadarImg/$i");
    # if we have it now, return it
    if (-f "/var/tmp/radar/$i" && -s "/var/tmp/radar/$i" > 331) {return $i;}
  }

  # this means we didnt get it at all!
  return;
}

=item create_radar_link($station,$type)

Returns a link to bc-image-overlay-nokml.pl for viewing $type radar
images for $station

=cut

sub create_radar_link {
  my($station,$type) = @_;
  # the GFW file
  my($gfw) = "${station}_${type}_0.gfw";

  # read/obtain the GFW file
  unless (-f $gfw) {
    system("curl -o $gfw http://radar.weather.gov/ridge/RadarImg/$type/$gfw");
  }

  # hash to store data
  my(%hash);
  # can't declare hash element in my, so splitting into three lines
  my($xp, $r1, $r2, $yp, $hw, $hn) = split(/\r\n/, read_file($gfw));
  $hash{w} = $hw;
  $hash{n} = $hn;
  # assuming file is 600x550 though this may change one day
  $hash{s} = $hash{n}+$yp*550;
  $hash{e} = $hash{w}+$xp*600;
  # center
  $hash{marker} = join(",", ($hash{n}+$hash{s})/2, ($hash{w}+$hash{e})/2);
  $hash{center} = $hash{marker};
  $hash{url} = "${station}-${type}.gif";
  $hash{key} = "radar_${type}_key.png";
  # this works for non-Conus images
  $hash{zoom} = 7;
  # this is probably pointless
  $hash{refresh} = 60;

  # join the keys and return URL
  my($qs) = join("&",map("$_=$hash{$_}", keys %hash));
  return "http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?$qs";
}

