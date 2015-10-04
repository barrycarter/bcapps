#!/bin/perl

# Rewrite of bc-hip2db.pl that uses "scat" <h>(runner-up for "worst
# possible name for a program")</h> to show the J2000 (not J1991.25 or
# B1950) cooridinates for stars AND the stellarium catalog for proper
# names when available. This rewrite does NOT create a database, just
# a file

# This is primarily so I can call bc-star-conjuncts.c with all
# "bright" stars "near" the ecliptic, so the output is in radians, NOT
# degrees or hms

require "/usr/local/lib/bclib.pl";

# TODO: do other skycultures have names for stars that wester doesn't?
# TODO: try to include constellation info for stars w odd names
# TODO: find Bayer names for other stars?

# read stellarium data
my(%starname);
for $i (split(/\n/,read_file("/usr/share/stellarium/skycultures/western/star_names.fab"))) {
  $i=~s/\s*(\d+)\|(.*?)$//||warn("BAD STAR: $i");
  $starname{$1}=$2;
}

# -n and -r very large just to print everything about 6.5
# -d = decimal degrees
# -m = limiting magnitude
# -j = use J2000 (0 0 = RA and DEC of 0)
# -h = header lines (which I ignore but are helpful to see)
# -c = catalog name
# NOTE: both files hipparcos and hipparcosra must exist and be identical

# first, ecliptic to search for stars w/in 15 degrees (which is slight
# overkill; Venus can be 8.25 degrees from ecliptic, so this allows
# for conjunctions up to 6+ degrees away)

my($out,$err,$res) = cache_command2("scat -h -n 9999999 -r 9999999 -d -s m -m 6.5 -e 0 0 -c $bclib{githome}/ASTRO/hipparcos", "age=999999");

debug("OUT: $out");

my(%close);

for $i (split(/\n/,$out)) {
  my($num,$lon,$lat,$mag1,$mag2,$mag3,$mag4) = split(/\s+/,$i);

  debug("MAGS: $mag1 $mag2 $mag3 $mag4");

  # -m 6.5 includes stars with no listed magnitudes as "0" mag, this
  # gets rid of them (there are no true 0 mag near enough to ecliptic)
  if ($mag eq "0.00") {next;}
  # normalizing to match to Stellarium (later)
  $num=~s/^0+//;

  debug($i," $num $lat");
  if (abs($lat)<=15) {$close{$num}=1;}
}

# and now, ra dec for the program
($out,$err,$res) = cache_command2("scat -h -n 9999999 -r 9999999 -d -s m -m 6.5 -j 0 0 -c $bclib{githome}/ASTRO/hipparcos", "age=999999");

# debug("ALPHA, out is: $out/$err/$res");

for $i (split(/\n/,$out)) {

  # skip headers
  unless ($i=~/^\d/) {debug("SKIPPING: $i"); next;}
  # special case for count line
  if ($i=~/hipparcos/) {next;}

  # get ra/dec ignore non-close to ecliptic
  my($num, $ra, $dec) = split(/\s+/,$i);
  $num=~s/^0+//;
  unless ($close{$num}) {debug("TOOFAR: $i"); next;}

  debug("GOT: $i");

  # star name instead of number
  if ($starname{$num}) {$num = $starname{$num};} else {$num="HIP$num";}

  # convert to radians and print
  printf("%.10f %.10f %s\n",$ra*$PI/180,$dec*$PI/180,$num);
}
