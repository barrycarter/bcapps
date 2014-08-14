#!/bin/perl

# Converts the Hipparcos star data into a database
# (ftp://cdsarc.u-strasbg.fr/pub/cats/I%2F239/)
# fields:
# 1 - HIP number
# 5 - magnitude
# 8,9 - ra/dec in ICRS J1991.25 (= bad?)

require "/usr/local/lib/bclib.pl";

system("rm /tmp/bchip.db");
open(A,"|tee /tmp/q1.txt|sqlite3 /tmp/bchip.db");
print A << "MARK";
CREATE TABLE stars (hipp INT, mag DOUBLE, ra DOUBLE, dec DOUBLE);
CREATE INDEX i1 ON stars(hipp);
CREATE INDEX i2 ON stars(mag);
CREATE INDEX i3 ON stars(ra);
CREATE INDEX i4 ON stars(dec);
BEGIN;
MARK
;

for $i (split(/\n/, `zcat /home/barrycarter/20140814/hip_main.dat.gz`)) {
  my(@l) = split(/\|/,$i);
  map($_=trim($_), @l);
  # at least one of ra/dec must be non-0
  unless ($l[8]||$l[9]) {next;}
  print A "INSERT INTO stars VALUES ($l[1], $l[5], $l[8], $l[9]);\n";
}

print A "COMMIT;\n";
close(A);



