#!/bin/perl

# based somewhat on DINK/bc-map2gmap.pl and DINK/bc-dinkles.pl, this
# program takes the output of:

# gdal_retile.py imagefile

# and glues the results into tiles representing more area but that are
# still 256x256 (actually just prints out montage commands)

require "/usr/local/lib/bclib.pl";

my($out, $err, $res) = cache_command2("ls");

# look through the ping files and find the row/col of this split up image

# TODO: this is really inefficient just to find rows/cols-- can I do
# more when I loop thru these files?

my($maxx, $maxy);

# keep track of filename since it can be pretty printed
my(%filename);

for $i (split(/\n/, $out)) {

  # ignore non-PNGs
  unless ($i=~/\.png$/) {next;}

  unless ($i=~/_(\d+)_(\d+)\.png$/) {
    warn ("BAD FILE: $i");
    next;
  }

  my($x, $y) = ($1, $2);

  $filename{$x}{$y} = $i;

  if ($x > $maxx) {$maxx = $x;}
  if ($y > $maxy) {$maxy = $y;}

}

debug("TILE MAP SIZE: $maxx by $maxy");

for $i (0..$maxx/2) {
for $j (0..$maxy/2) {
  debug("IJ: $i, $j");
}
}

# TODO: check for filler tile, almost always needed
