#!/bin/perl

# converts the SRTM data to a big binary file that covers the Earth

# TODO: 65535 header or something (1M?)

# final file size is 360*1200 for longitude and 180*1200 for latitude
# times 2 bytes per data point, so 186.624 GB (uncompressed)

require "/usr/local/lib/bclib.pl";

my($fname) = @ARGV;

$| = 1;

open(A, "zcat $fname|");

my(@arr);

# first 6 rows are header lines
for $i (0..5) {$arr[$i] = <A>;}

my(%meta);

for $i (@arr) {
  $i=~s/^(.*?)\s+(.*)$//;
  $meta{$1} = $2;
}

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
