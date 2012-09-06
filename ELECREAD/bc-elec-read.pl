#!/bin/perl

# read electric meter automatically

require "/usr/local/lib/bclib.pl";

# these are roughly the 5 center points of the dials in any image
# images are 448x140

# 67,60
# 149,68
# 232,77
# 314,85
# 390,92

# center position after rotation of -5.6579 degs

# 72,97
# 155, 97 (83px shift)
# 238,97 (83px shift)
# 320,97 (82px shift) [321 works pretty well too]
# 399,97 (79px shift) [400 works, but 403 does not]

# straigten image and then slice into 5 dials
system("convert -rotate -5.6579 20120617.173402.jpg /tmp/bcer0.pnm");

for $i (0..4) {
  # left of circle
  my($pos) = 72+82*$i-80/2;
  # ypos is fixed at 97-83/2 (assuming true circles)
  system("convert -crop 83x83+$pos+55 /tmp/bcer0.pnm /tmp/bcer2-$i.pnm");
}

die "TESTING";


# general idea is to read circles radiating out from center points and
# find "darkest point" for each dial

# This is for testing only
# PNM is also the name of my power company
system("convert 20120617.173402.jpg /tmp/bcer1.pnm");
@pnm = pnm("/tmp/bcer1.pnm");

# debug(unfold($pnm[32]));

# search outwards starting at dial 1 (TODO: other dials)
# NOTE: dial 1 changes least and is least important

# the "east edge" at 10 pixels

# debug(unfold($pnm[15]), $#pnm);

for $j (-10..10) {
 debug("10,$j: ",$pnm[67+10][60+$j]);
}



=item pnm($file)

Given a PNM format graphic $file, return array of pixels (format is row,pixel)

=cut

sub pnm {
  my($file) = @_;
  my($all) = read_file($file);

  # find the x and y dims (first three lines are info lines, 2nd is dims)
  $all=~s/^(.*?)\n(.*?)\n(.*?)\n//s;
  my($x,$y) = split(/\s+/,$2);

  my(@ret);

  for $i (0..$y) {
    # translate pixels into numbers, row by row
    my($row) = substr($all,$x*$i,$x);
    my(@pix) = map($_=ord($_),split(//,$row));
    push(@ret,\@pix);
  }

  return @ret;
}

