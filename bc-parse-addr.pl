#!/bin/perl -00

# parses the output of applying "ogrinfo -al" to the base.shp file in
# http://www.cabq.gov/gisshapes/base.zip (using base.dbf yields the
# exact same results, upto:

# < INFO: Open of `base.dbf'
# ---
# > INFO: Open of `base.shp'

# Unfortunately, both base.zip and the output of ogrinfo -al are too
# big to keep in GIT, even bzip2'd

require "/usr/local/lib/bclib.pl";

open(A,"bzcat /home/barrycarter/20120612/BASE/ogrinfo.al.base.shp.bz2|");

while (<A>) {
  debug("THUNK: $_");
}

