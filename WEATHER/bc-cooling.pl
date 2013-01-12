#!/bin/perl

# on a clear night, is temperature decrease a function of current temperature

require "/usr/local/lib/bclib.pl";

# could be more precise below
# earliest twiling start = 0422 or 1122 GMT
# latest twilight end in ABQ: 1954 or 0254 GMT
# safe GMT hours 3-11 inclusive

# testing
$year = "1981";
@obs = `zcat /mnt/sshfs/isd-lite/$year/723560-13968-$year.gz`;

for $i (@obs) {
  chomp($i);

  # split into fields
  @f = split(/\s+/,$i);

  # ignore nonclear sky readings
  if ($f[9]) {next;}

  # ignore non-night readings
  unless ($f[3]>=3 && $f[3]<=11) {next;}

  # ignore missing readings
  if ($f[4] == -9999) {next;}

  push(@obs2, $i);
}

# find consecutive readings
for $i (0..$#obs2-1) {
  @f1 = split(/\s+/,$obs2[$i]);
  @f2 = split(/\s+/,$obs2[$i+1]);

  # this is a horrible way to test AND misses case hour 23 to hour 0 jump
  unless ($f1[0]==$f2[0] && $f1[1]==$f2[1] && $f1[2]==$f2[2] && $f2[3]-$f1[3]==1) {next;}

  # the change
  $diff = $f2[4]-$f1[4];

  # and print old new temp (or diff)
#  print "$f1[4] $f2[4]\n";
  print "$f1[4] $diff\n";
#  debug("X:",$obs2[$i],"Y",$obs2[$i+1]);
}


