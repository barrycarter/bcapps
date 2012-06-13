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

and we only need the full address (at least for now?), so:

ALTER TABLE abq3 ADD full_address TEXT;
UPDATE abq3 SET full_address = TRIM(
streetnumb||'|'||COALESCE(streetname,'')||'|'||COALESCE(streetdesi,'')||
'|'||COALESCE(streetquad,''));

SELECT full_address||'|'||centroid FROM abq3;

(output of above is in db/abqaddr.bz2)

=cut

require "/usr/local/lib/bclib.pl";
open(A,"bzcat /home/barrycarter/BCGIT/db/abqaddr.bz2|");

while (<A>) {
  $_ = trim($_);
  ($num, $sname, $stype, $sdir, $latlon) = split(/\|/, $_);

  # if addr is 0 or missing, pointless
  unless ($num) {next;}

  # get lat lon (or skip if NA)
  unless ($latlon=~/^POINT\((.*?)\s+(.*?)\)$/) {next;}
  ($lon, $lat) = ($1, $2);

  # obtain OSM data for this chunk (to avoid duplicating stuff!)
  # caching is important here, so normalizing to 1/100th degree
  $url = sprintf("http://api.openstreetmap.org/api/0.6/map/?bbox=%.2f,%.2f,%.2f,%.2f", $lon, $lat, $lon+.01, $lat+.01);
  $sha = sha1_hex($url);

  # have I dl'd this URL before?
  unless (-f "/var/tmp/OSM/$sha") {
    ($out, $err, $res) = cache_command("curl -o /var/tmp/OSM/$sha '$url'");
  }

  $data = read_file("/var/tmp/OSM/$sha");
  $n++;

  if ($data=~/$num $sname/is) {
    debug("FOUND($n) $num $sname in $sha!");
  } else {
    # do nothing
  }
}

close(A);


