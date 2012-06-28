#!/bin/perl

# adds ABQ street addresses to OSM (openstreetmap.org)

=item proc

Procedure to obtain ABQ centroid address list:

  - download and unzip http://www.cabq.gov/gisshapes/base.zip

  - note that base.shp.xml says:

<projcsn Sync="TRUE">
NAD_1983_HARN_StatePlane_New_Mexico_Central_FIPS_3002_Feet
</projcsn>

and http://resources.esri.com/help/9.3/arcgisserver/apis/rest/pcs.html
tells us this is SRID 2903

  - shp2pgsql -s 2903 base abq3 | psql > /dev/null;: (use version 8.2 of
  shp2pgsql or later; earlier versions will work, but not yield any
  useful information)

WGS84 is SRID4326
(http://postgis.refractions.net/docs/using_postgis_dbmanagement.html),
so

ALTER TABLE abq3 ADD centroid TEXT;
UPDATE abq3 SET centroid = ST_ASTEXT(ST_TRANSFORM(ST_CENTROID(the_geom),4326));

<h>COALESCE would make a good street name</h>

And get the data:

ALTER TABLE abq3 ADD data_export TEXT;

UPDATE abq3 SET data_export = TRIM(
COALESCE(lot,'')||'|'||
COALESCE(block,'')||'|'||
COALESCE(subdivisio,'')||'|'||
COALESCE(streetnumb,0)||'|'||
COALESCE(streetname,'')||'|'||
COALESCE(streetdesi,'')||'|'||
COALESCE(streetquad,'')||'|'||
COALESCE(apartment,'')||'|'||
COALESCE(pin,'')||'|'||
COALESCE(centroid,'')
);

SELECT data_export FROM abq3; (output of this is in db/abqaddr.bz2)

=cut

require "/usr/local/lib/bclib.pl";
open(A,"bzcat /home/barrycarter/BCGIT/db/abqaddr.bz2|");

while (<A>) {
  $_ = trim($_);
  ($lot, $block, $subdivision, $num, $sname, $stype, $sdir, $apt, $pin,
$latlon) = split(/\|/, $_);

  # if addr is 0 or missing, pointless
  unless ($num) {next;}

  # get lat lon (or skip if NA)
  unless ($latlon=~/^POINT\((.*?)\s+(.*?)\)$/) {next;}
  ($lon, $lat) = ($1, $2);

  # obtain OSM data for this chunk (to avoid duplicating stuff!)
  # caching is important here, so normalizing to 1/100th degree
  $url = sprintf("http://api.openstreetmap.org/api/0.6/map/?bbox=%.2f,%.2f,%.2f,%.2f", $lon, $lat, $lon+.01, $lat+.01);
  my($outfile) = osm_cache_bc($lat,$lon);

debug("OUTFILE: $outfile");

warn "TESTING";
next;

  # have I dl'd this URL before?
  unless (-f $outfile) {
    ($out, $err, $res) = cache_command("curl -o $outfile '$url'");
  }

  $data = read_file($outfile);
  $n++;

  if ($data=~/$num $sname/is) {
    debug("FOUND($n) $num $sname in $sha!");
    next;
  }

  # at this point, we need to add (or at least record that we need to add)
  push(@{$list{$sha}}, $_);
}

close(A);

# <h>I wonder if there's treatment for excessive sorting disease</h>
for $i (sort keys %list) {
  $list = join("\n", sort(@{$list{$i}}));
  debug("LIST: $list");
#  write_file($list, "/var/tmp/OSM/put-$i");
}




