#!/bin/perl

# converts the SRTM data to a big binary file that covers the Earth

# the valid x values are: 0 to 431999
# the valid y values are: 0 to 216000 (allowing one extra pixel)

# final file size is 360*1200 for longitude and 180*1200 for latitude
# times 2 bytes per data point, so 186.624 GB + 1M header (uncompressed)

require "/usr/local/lib/bclib.pl";

# reserve 1M bytes for header
my($reserve) = 10**6;

my($fname) = @ARGV;

open(A, "zcat $fname|");

# first 6 rows are header lines
my(@arr);
for $i (0..5) {$arr[$i] = <A>;}

# meta data
my(%meta);
for $i (@arr) {
  $i=~s/^(.*?)\s+(.*)$//;
  $meta{$1} = $2;
}

# because the big file (186+G) is fixed, we hardcode a little

# we adjust lower left corner latitude and longitude by turning them
# into row/col coordinates (positive and a multiple of cellsize)

# we then add 1/2 to each (and round) so they represent the lowest
# left value, which is 1/2 cellsize away in each direction from the
# corner

my($adjlat) = round(($meta{yllcorner}+90)*1200+1/2);
my($adjlon) = round(($meta{xllcorner}+180)*1200+1/2);

# for speed, we compute the adjusted lat/lon for each row/col (we are
# 0-indexed)

my(@row2lat, @col2lon);

for ($i=$meta{nrows}-1; $i>=0; $i--) {$row2lat[$i] = $adjlat++;}
  
for $i (0..$meta{ncols}-1) {$col2lon[$i] = $adjlon++;}

my($row) = 0;

while (<A>) {

  # ignore impossible latitudes with a warning
  if ($row2lat[$row] < 0 || $row2lat[$row] > 216000) {
    warn "Ignoring bad latitude: $row -> $row2lat[$row]";
    next;
  }

  my(@cols) = split(/\s+/, $_);

  for $col (0..$#cols) {

    # ignore impossible longitudes with a warning
    if ($col2lon[$col] < 0 || $col2lon[$col] > 431999) {
      warn "Ignoring bad longitude: $col -> $col2lon[$col]";
      next;
    }

    # the byte position in the mega file (2 bytes per data point)
    my($byte) = $row2lat[$row]*2*432000 + $col2lon[$col]*2 + $reserve + 1;

    # the value to post, converted to bytes
    # this makes -9999 -> 0 = missing value
    my($post) = $cols[$i] + 9999;
    my($b1) = floor($post/256);
    my($b2) = $post%256;

  }
  $row++;

  if ($row%100 == 0) {debug("ROW: $row");}

}


exit(0);

while (<>) {

  unless (/^\s*[\-\d]/) {
    warn "BAD LINE: $_";
    next;
  }

  my(@vals) = split(/\s+/, $_);

  for $i (@vals) {
    my($val) = $i==-9999?0:$i + 32767;
    my($b1) = floor($val/256);
    my($b2) = $val%256;
    print chr($b1),chr($b2);
  }

}
