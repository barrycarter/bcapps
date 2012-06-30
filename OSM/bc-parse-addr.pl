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

warn "Need changeset to actually do something with this program!";

# open(A,"bzcat /home/barrycarter/BCGIT/db/abqaddr.bz2|");

open(A,"/tmp/randomaddr.txt");

warn "Using random sorted version solely for testing";

warn "Testing, do not use!";

while (<A>) {
  $_ = trim($_);
  ($lot, $block, $subdivision, $num, $sname, $stype, $sdir, $apt, $pin,
$latlon) = split(/\|/, $_);

  # if addr is 0 or missing, pointless
  # 99999 also indicates some sort of weirdness
  unless ($num && $num != 99999) {next;}

  # get lat lon (or skip if NA)
  unless ($latlon=~/^POINT\((.*?)\s+(.*?)\)$/) {next;}
  ($lon, $lat) = ($1, $2);

  $data = osm_cache_bc($lat,$lon);
  $n++;

  if ($n%1000==0) {debug("COUNT: $n");}

  if ($data=~/$num $sname/is) {
    debug("FOUND($n) $num $sname in $sha!");
    next;
  }

  # determine street address (base.zip doesn't include it sadly)
  my($saddr) = "$num $sname $stype $sdir";
  if ($apt) {$saddr = "$saddr #$apt";}

  # strip extra spaces
  $saddr=~s/\s+/ /isg;
  $saddr=trim($saddr);

  debug("SADDR: *$saddr*");
  next;

  # this is the XML to add this address
  # meta-tags will appear in changeset only
my($xml) = << "MARK";

<node id="-1" lat="$lat" lon="$lon" changeset="0">
<tag k='' v='' />

</node>
MARK
;

  # at this point, we need to add (or at least record that we need to add)
  push(@{$list{$sha}}, $_);
}

close(A);

# <h>I wonder if there's treatment for excessive sorting disease</h>
for $i (sort keys %list) {
  $list = join("\n", sort(@{$list{$i}}));
 # debug("LIST: $list");
  write_file($list, "/var/tmp/OSM/thelist");
}




