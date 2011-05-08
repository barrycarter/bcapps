#!/bin/perl

# Obtains weather data from the APRS stream <h>and does absolutely
# nothing with it</h>

require "bclib.pl";
use Fcntl;
chdir(tmpdir());

# <h>let's do the time zone again</h>
$ENV{TZ} = "GMT";

for(;;) {

  # if we've been waiting too long for a line, something's wrong so restart;
  # this also handles startup case where $lastlinetime isn't defined yet
  $since = time()-$lastlinetime;
  if ($since > 10) {do_connect();}

  # read next line, but ignore + sleep if blank
  unless ($line = <A>) {sleep 1; next;}

  # we have a valid line, so update lastlinetime
  $lastlinetime = time();

  # process line
  %hash = parse_line($line);

  unless (%hash) {next;}

  # query
  $query = "REPLACE INTO aprswx (station, time, lat, lon, temp) VALUES
 ('$hash{speaker}', '$hash{utime}', '$hash{lat}', '$hash{lon}', '$hash{temp}')";

  push(@queries, $query);

  # how long has it been since last update (push to db?)
  $dbsince = time()-$lastupdate;
  if ($dbsince > 10) {do_update();}
}

sub do_update {
  my(@vpoints);
  my(@temp);
  my(@polys);

  # calling this resets $lastupdate
  $lastupdate = time();

  # nuke entries older than an hour or in the future
  my($now) = time();
  my($cull) = $now - 3600;
#  debug("CULL: $cull");
  push(@queries, "DELETE FROM aprswx WHERE time+0 < $cull OR time+0 > $now");

  # run queries in transaction
  unshift(@queries, "BEGIN");
  push(@queries, "COMMIT;\n");
  my($query) = join(";\n", @queries);
  write_file($query, "queries");
  debug("QUERIES:",read_file("queries"));
  system("sqlite3 /home/barrycarter/20110507/aprswx.db < queries");

  # now, pull data are create KML file
  my(@res)=sqlite3hashlist("SELECT lat,lon,temp FROM aprswx", "/home/barrycarter/20110507/aprswx.db");

  unless ($#res>=0) {
    debug("NO RECORDS YET...");
    return;
  }

  for $i (0..$#res) {
    my(%hash) = %{$res[$i]};
    # the voronoi point list
    push(@vpoints, $hash{lon}, $hash{lat});
    # keep track of temperature
    $temp[$i] = $hash{temp};
  }


  # create diagram
  # TODO: for now, using equiangular mapping
  my(@poly) = voronoi(\@vpoints);

  # create KML for each polygon, first determining color
  for $i (0..$#poly) {
    my($hue) = 5/6-($temp[$i]/100)*5/6;
    my($col) = hsv2rgb($hue,1,1,"kml=1&opacity=60");
    push(@mypolys, poly_kml($poly[$i], $col));
  }

  # KML header
  my($kmlhead) = << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
MARK
;
  # KML footer
  my($kmlfoot) = "</Document></kml>\n";

  # polygons
  my($polystring) = join("\n",@mypolys)."\n";

  # write to file
  write_file("$kmlhead$polystring$kmlfoot", "/home/barrycarter/BCINFO/sites/TEST/aprswx.kml");

  debug("UPDATED!");

  return;
}

# given a polygon and a color, return KML for it (specific to this script)
sub poly_kml {
  my($poly, $col) = @_;
  my(@coords);
  # pretend static var
  $static{count}++;

  # style
  my($style) = << "MARK";
<Style id="$static{count}">
<PolyStyle><color>$col</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;

  # polygon header
  my($polyhead) = << "MARK";
<Placemark><gx:balloonVisibility>0</gx:balloonVisibility>
<styleUrl>\#$static{count}</styleUrl>
<title>TITLE</title>
<description>BLANK</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;

  my(@poly) = @{$poly};
  map(s/ /,/isg, @poly);

  # the coordinates
  my($polybody) = join("\n", @poly)."\n";

  # footer
  my($polyfoot) = << "MARK";
</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>
MARK
;

  return "$style$polyhead$polybody$polyfoot";
}

# make connection to APRS server, perhaps unsuccessfuly
sub do_connect {

  # TODO: calling this resets lastlinetime, but should it?
  $lastlinetime = time();

  debug("(RE)CONNECTING");
  close(A);
  # could "use Socket" here but this is cooler?
  open(A,"echo 'user READONLY pass -1' | ncat rotate.aprs.net 23 |") || warn("FAIL: Error, $!");
  # unblock socket just in case we get disconnected
  fcntl(A,F_SETFL,O_NONBLOCK|O_NDELAY);
}

# parse an APRS line, returning a hash of values, or blank if line is
# not in WX format

sub parse_line {
  my($line) = @_;
  my(%hash) = ();
  my($lat, $lats, $lon, $lons, $da, $ho, $mi);

  # grab temperature data, return if none
  # TODO: this is an inaccurate and improper way to find weather data
  # 't' is case sensitive
  unless (($hash{temp}) = ($line=~/t(\d{3})/)) {return();}

  # latitude/longitude
  unless (($lat, $lats, $lon, $lons) =
 ($line=~m%([\d\.]{3,})([N|S])/([\d\.]{3,})([E|W])%)) {return();}

  # observation time
  unless (($da, $ho, $mi)=($line=~m%(\d{2})(\d{2})(\d{2})z%i)) {return();}

  # we now know we have a valid line, so process it

  # convert time to unix time
  # TODO: ignoring corner case: today is 1st of month, report was on
  # last day of previous month
  # find current month (rest of info is useless)
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());
  # and now, mktime
  $hash{utime} = mktime(0, $mi, $ho, $da, $mon, $year);

  # "speaker" (probably shouldve been station?)
  ($hash{speaker}) = ($line=~m%^(.*?)>%);

  # decimalize latitude/longitude (TODO: functionalize this)
  my($latd) = floor($lat/100);
  my($latm) = $lat - $latd*100;
  $hash{lat} = $latd+$latm/60;
  if ($lats eq "S") {$hash{lat}*=-1;}

  my($lond) = floor($lon/100);
  my($lonm) = $lon - $lond*100;
  $hash{lon} = $lond+$lonm/60;
  if ($lons eq "W") {$hash{lon}*=-1;}

  return %hash;

}

# Format: "@221533z2950.68N/09529.95W_308"

=item schema

database to hold these (latest report from station obsoletes prior report):

CREATE TABLE aprswx (station, time, lat, lon, temp);
CREATE UNIQUE INDEX i1 ON aprswx(station);

=cut
