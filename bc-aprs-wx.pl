#!/bin/perl

# Obtains weather data from the APRS stream <h>and does absolutely
# nothing with it</h>

require "bclib.pl";
use Fcntl;
chdir(tmpdir());

warn "TESTING";
do_update(); # for testing, jump to this

# <h>let's do the time zone again</h>
$ENV{TZ} = "GMT";

for(;;) {

  # if we've been waiting too long for a line, something's wrong so restart;
  # this also handles startup case where $lastlinetime isn't defined yet
  $since = time()-$lastlinetime;
  if ($since > 1) {debug("SINCE: $since");}
  if ($since > 10) {
    debug("(RE)STARTING");
    close(A);
    # could "use Socket" here but this is cooler?
    open(A,"echo 'user READONLY pass -1' | ncat rotate.aprs.net 23 |") || warn("FAIL: Error, $!");
    # unblock socket just in case we get disconnected
    fcntl(A,F_SETFL,O_NONBLOCK|O_NDELAY);
    # TODO: does reset count as reading a line?
    $lastlinetime = time();
  }

  $line = <A>;

  # if we see a blank line, chill for a bit
  unless ($line) {sleep 1; next;}

  $lastlinetime = time();

#  debug("LINE: $line");

  # TODO: this is an inaccurate and improper way to find weather data
  # 't' is case sensitive
  unless (($temp) = ($line=~/t(\d{3})/)) {next;}
  # strip leading 0s
  $temp=~s/^0+//isg;

  # latitude/longitude
  unless (($lat, $lats, $lon, $lons) =
 ($line=~m%([\d\.]{3,})([N|S])/([\d\.]{3,})([E|W])%)) {
#    debug("BAD POS: $line");
    next;
  }

  # time
  unless (($da, $ho, $mi)=($line=~m%(\d{2})(\d{2})(\d{2})z%i)) {
#    debug("BAD TIME: $line");
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
  ($speaker) = ($line=~m%^(.*?)>%);

  # decimalize latitude/longitude (TODO: functionalize this)
  $latd = floor($lat/100);
  $latm = $lat - $latd*100;
  $latfinal = $latd+$latm/60;
  if ($lats eq "S") {$latfinal*=-1;}

  $lond = floor($lon/100);
  $lonm = $lon - $lond*100;
  $lonfinal = $lond+$lonm/60;
  if ($lons eq "W") {$lonfinal*=-1;}

  push(@queries, "REPLACE INTO aprswx (station, time, lat, lon, temp) VALUES
 ('$speaker', '$utime', '$latfinal', '$lonfinal', '$temp')");

#  print "$speaker $utime $latfinal $lonfinal ${temp}F\n";

  # how long has it been since last update (push to db?)
  $dbsince = time()-$lastupdate;
  debug("DBSINCE: $dbsince");
  if ($dbsince > 10) {do_update();}

}

sub do_update {
  my($count);

  # run queries in transaction
  unshift(@queries, "BEGIN");

  # nuke entries older than an hour
  my($cull) = time() - 3600;
  push(@queries, "DELETE FROM aprswx WHERE time < $cull");
  push(@queries, "COMMIT;\n");
  my($query) = join(";\n", @queries);

  write_file($query, "queries");
  system("sqlite3 /home/barrycarter/20110507/aprswx.db < queries");

  # now, pull data are create KML file
  my(@res)=sqlite3hashlist("SELECT lat,lon,temp FROM aprswx", "/home/barrycarter/20110507/aprswx.db");

  # voronoi points
  my(@vpoints);

  # keep track of temperature
  my(%tempr) = ();

  for $i (@res) {
    my(%hash) = %{$i};
    push(@vpoints, $hash{lon}, $hash{lat});
    # TODO: indexing on real numbers is really really bad
    $tempr{$hash{lon}}{$hash{lat}} = $hash{temp};
  }

  # create diagram
  # TODO: for now, using equiangular mapping
  my(@poly) = voronoi(\@vpoints);

  # this will hold the style + polygon portion of the KML file
  my(@polys);

  # and now KML file
  for $i (@poly) {

    # style for this polygon
    $count++;
    push(@poly, '<Style id="$count">');
    push(@poly, '<PolyStyle><color>$kmlcol</color>');
    push(@poly, '<fill>1</fill><outline>0</outline></PolyStyle></Style>');

    push(@polys, "<Placemark><Polygon><outerBoundaryIs><LinearRing><coordinates>");
    for $j (@{$i}) {
      $j=~s/ /,/isg;
      push(@polys, $j);
    }
    push(@polys, "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>");
  }

  # KML header
  my($kml) = << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
MARK
;

  # and the polygons combined
  my($poly) = join("\n",@polys)."\n";
  write_file("$kml\n$poly\n</Document></kml>\n", 
"/home/barrycarter/BCINFO/sites/TEST/aprswx.kml");

#  debug(unfold(@poly));
  debug(@polys);
  die "TESTING";

  # reset
  @queries = ();
  $lastupdate = time();
}

# Format: "@221533z2950.68N/09529.95W_308"

=item schema

database to hold these (latest report from station obsoletes prior report):

CREATE TABLE aprswx (station, time, lat, lon, temp);
CREATE UNIQUE INDEX i1 ON aprswx(station);

=cut
