#!/bin/perl

# on a clear night, is temperature decrease a function of current temperature

require "/usr/local/lib/bclib.pl";

# could be more precise below
# earliest twiling start = 0422 or 1122 GMT
# latest twilight end in ABQ: 1954 or 0254 GMT
# safe GMT hours 3-11 inclusive

# testing
$year = "1980";
@obs = `zcat /mnt/sshfs/isd-lite/$year/723560-13968-$year.gz`;

for $i (@obs) {
  chomp($i);

  # split into fields
  @f = split(/\s+/,$i);

  # ignore nonclear sky readings
  if ($f[9]) {next;}

  # ignore non-night readings
  unless ($f[3]>=3 && $f[3]<=11) {next;}

  push(@obs2, $i);
}

debug(@obs2);


