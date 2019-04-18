#!/bin/perl

# converts the SRTM data to a big binary file that covers the Earth

# TODO: 65535 header or something (1M?)

# the valid x values are: 0 to 431999
# the valid y values are: 0 to 216000 (allowing one extra pixel)

# final file size is 360*1200 for longitude and 180*1200 for latitude
# times 2 bytes per data point, so 186.624 GB (uncompressed)

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

# assign latitude values to each row; because of our numbering scheme,
# the last row is nrows-1

my($curlat) = $meta{yllcorner} + $meta{cellsize}/2;

for ($i = $meta{nrows}-1 ; $i >= 0; $i--) {
  $row2lat[$i] = $curlat;

  # the "adjusted latitude" adds 90 for all positives and divides by cellsize
  $adjlat[$i] = ($curlat+90)/$meta{cellsize};

  # if it's not sufficiently close to its rounded value, worry; otherwise round
  my($round) = round($adjlat[$i]);
  if (abs($round - $adjlat[$i]) > 0.1) {die "BAD ROUND: $i";}
  $adjlat[$i] = $round;

  $curlat += $meta{cellsize};
}

# same thing for longitude

my($curlon) = $meta{xllcorner} + $meta{cellsize}/2;

for $i (0..$meta{ncols}-1) {
  $col2lon[$i] = $curlon;

  # the "adjusted longitude" adds 180 for all positives and divides by cellsize
  $adjlon[$i] = ($curlon+180)/$meta{cellsize};

  # if it's not sufficiently close to its rounded value, worry; otherwise round
  my($round) = round($adjlon[$i]);
  if (abs($round - $adjlon[$i]) > 0.1) {die "BAD ROUND: $i";}
  $adjlon[$i] = $round;

  # special case wraparound
  # TODO: don't hardcode value below
  if ($adjlon[$i] == 432000) {$adjlon[$i] = 0;}

  $curlon += $meta{cellsize};
}

debug(@adjlon);

die "TESTING";




my($row) = 0;

while (<A>) {

  my(@cols) = split(/\s+/, $_);

  # the latitude associated with this row
  my($lat) = $meta{cellsize}*($row + 3/2-$meta{nrows}) + $meta{yllcorner};

  for $i (0..$#cols) {
    # longitude for this column
    # TODO: this is insanely inefficent
    my($lon) = $meta{cellsize}*($i+1/2) + $meta{xllcorner};
    debug("ROW: $row, COL: $i, LAT: $lat, LON: $lon, VAL: $cols[$i]");
  }

  $row++;
}

# debug(%meta);

die "TESTING";

my(%meta);

debug("NCOLS: $ncols");

die "TESTING";

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
