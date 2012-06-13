#!/bin/perl -00

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
UPDATE abq3 SET full_address = 
TRIM(streetnumb||' '||COALESCE(streetname,'')||' '||COALESCE(streetdesi,'')||' '||COALESCE(streetquad,''));

SELECT full_address||','||centroid FROM abq3 LIMIT 50;

=cut

# parses the output of applying "ogrinfo -al" to the base.shp file in
# http://www.cabq.gov/gisshapes/base.zip (using base.dbf yields the
# exact same results, upto:

# < INFO: Open of `base.dbf'
# ---
# > INFO: Open of `base.shp'

# Unfortunately, both base.zip and the output of ogrinfo -al are too
# big to keep in GIT, even bzip2'd

# each item of data is separated by double newline, thus the "-00" above

require "/usr/local/lib/bclib.pl";

open(A,"bzcat /home/barrycarter/20120612/BASE/ogrinfo.al.base.shp.bz2|");

while (<A>) {
  

  debug("THUNK: $_");
}

