#!/bin/perl

# quick and dirty check of timezones in zone.tab

require "/usr/local/lib/bclib.pl";

@tab = split(/\n/,read_file("/usr/share/zoneinfo/zone.tab"));
@fil = `find /usr/share/zoneinfo -type f`;

# for zone.tab, remove comments, otherwise note as zone
for $i (@tab) {
  chomp($i);
  if ($i=~/^\#/) {next};
  @l = split(/\s+/,$i);
  $istz{$l[2]} = 1;
}

# for files, remove leading dir
for $i (@fil) {
  chomp($i);
  $i=~s%^/usr/share/zoneinfo/%%;
  $istz{$i} = 1;
}

# this is inefficient, should use localtime()

for $i (sort keys %istz) {
  $ENV{TZ} = $i;
  print "TZ: $i ".`date`;
}

=item comments

Sample use (if output piped to tzs.txt):

grep 'dec 30' tzs.txt | sort -k6n

=cut

