#!/bin/perl

# Obtains weather data from the APRS stream <h>and does absolutely
# nothing with it</h>

require "bclib.pl";
use Fcntl;

# <h>let's do the time zone again</h>
$ENV{TZ} = "GMT";

# could "use Socket" here but this is cooler?
open(A,"echo 'user READONLY pass -1' | ncat rotate.aprs.net 23 |");

# unblock socket just in case we get disconnected
fcntl(A,F_SETFL,O_NONBLOCK|O_NDELAY);

# confirm connection
while (<A>) {
  debug($_);
  print STDERR "Diagnostic: $_\n)";
  if (/verified/i) {
    debug("CONFIRMED");
    last;
  }
}

for(;;) {
  $line = <A>;

  # if we've been waiting too long for a line, something's wrong
  if ((time()-$lastlinetime) > 30) {
    debug("WAITING!");
    # TODO: restart process above
  }

  # if we see a blank line, chill for a bit
  unless ($line) {sleep 1;}

  $lastlinetime = time();

  debug($line);

  # TODO: this is an inaccurate and improper way to find weather data
  # 't' is case sensitive
  unless (($temp) = ($line=~/t(\d{3})/)) {next;}
  # strip leading 0s
  $temp=~s/^0+//isg;

  # latitude/longitude
  unless (($lat, $lats, $lon, $lons) =
 ($line=~m%([\d\.]{3,})([N|S])/([\d\.]{3,})([E|W])%)) {
    debug("BAD POS");
    next;
  }

  # time
  unless (($da, $ho, $mi)=($line=~m%(\d{2})(\d{2})(\d{2})z%i)) {
    debug("BAD TIME");
    next;
  }

  # convert to Unix
  # find current month (rest of info is useless)
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());
  # and now, mktime
  $utime = mktime(0, $mi, $ho, $da, $mon, $year);

  # TODO: ignoring corner case: today is 1st of month, report was on
  # last day of previous month

  # "speaker"
  $speaker = ($line=~m%^(.*?)>%);

  # decimalize latitude/longitude (TODO: functionalize this)
  $latd = floor($lat/100);
  $latm = $lat - $latd*100;
  $latfinal = $latd+$latm/60;
  if ($lats eq "S") {$latfinal*=-1;}

  $lond = floor($lon/100);
  $lonm = $lon - $lond*100;
  $lonfinal = $lond+$lonm/60;
  if ($lons eq "W") {$lonfinal*=-1;}

  print "$speaker $utime $latfinal $lonfinal ${temp}F\n";

  # how long has it been since last update (push to db?)
  if ((time()-$lastupdate) > 60) {do_update();}

}

# TODO: everything
sub do_update {
  $lastupdate = time();
}

# Format: "@221533z2950.68N/09529.95W_308"

=item schema

database to hold these (latest report from station obsoletes prior report):

CREATE TABLE aprswx (station, lat, lon, temp);
CREATE UNIQUE INDEX ON aprswx(station);

=cut
