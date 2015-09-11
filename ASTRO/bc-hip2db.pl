#!/bin/perl

# Rewrite of bc-hip2db.pl that uses "scat" <h>(runner-up for "worst
# possible name for a program")</h> to show the J2000 (not J1991.25 or
# B1950) cooridinates for stars AND the stellarium catalog for proper
# names when available. This rewrite does NOT create a database, just
# a file

# This is primarily so I can call bc-star-conjuncts.c with all
# "bright" stars, although is fairly silly, since planets won't get
# close to most of these stars (but the program runs fast enough as
# is, so I don't care?)

# TODO: find Bayer names for other stars?
# TODO: only print stars w/in 8.5 degree of ecliptic (Venus) (-e ?)

require "/usr/local/lib/bclib.pl";

# TODO: do other skycultures have names for stars that wester doesn't?
# TODO: try to include constellation info for stars w odd names
# read stellarium data
for $i (split(/\n/,read_file("/usr/share/stellarium/skycultures/western/star_names.fab"))) {
  $i=~s/\s*(\d+)\|(.*?)$//||warn("BAD STAR: $i");
}

# -n and -r very large just to print everything about 6.5
# -d = decimal degrees
# -m = limiting magnitude
# -j = use J2000 (0 0 = RA and DEC of 0)
# -c = catalog name
# NOTE: both files hipparcos and hipparcosra must exist and be identical
open(A,"scat -n 9999999 -r 9999999 -d -s m -m 6.5 -j 0 0 -c $bclib{githome}/ASTRO/hipparcos|");

while (<A>) {
  my($num, $ra, $dec);

  debug("GOT: $_");
}

die "TESTING";

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



