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

# even at radius 18, bumping into numbers
# at radius 11, hitting "bulby" part of needle

# straigten image and then slice into 5 dials
system("convert -rotate -5.6579 20120702.121702.jpg /tmp/bcer0.pnm");

for $i (0..4) {
  # left of circle
  my($pos) = 72+82*$i-80/2;
  # ypos is fixed at 97-83/2 (assuming true circles)
  # TODO: remove -monochrome
  system("convert -colorspace gray -crop 83x83+$pos+55 /tmp/bcer0.pnm /tmp/bcer2-$i.pnm");
}

# general idea is to read circles radiating out from center points and
# find "darkest point" for each dial

# This is for testing only
# PNM is also the name of my power company

# TODO: need to loop through the files
@pnm = pnm("/tmp/bcer2-2.pnm");

# TODO: need to loop through the numbers (images)

# for each radius

for $radius (12..17) {
  %hash = ();
  # each point on radius (this might be redundant)
  for $i (0..$radius*4) {
    $x = round(83/2+$radius*cos($i*$radius*4/2/$PI));
    $y = round(83/2+$radius*sin($i*$radius*4/2/$PI));
    $hash{"$x,$y"} = $pnm[$y][$x];
  }

  my(@keys) = sort {$hash{$a} <=> $hash{$b}} keys %hash;

  # no need for full sort above, but OK
  my($minx,$miny) = split(/\,/, $keys[0]);
  #debug("$minx,$miny");
# reversal of y direction: image vs trig
  my($ang) = fmodp(90-atan2(83/2-$miny,$minx-83/2)*$RADDEG,360);
  # TODO: correct for even numbered meters where numbers are reversed
  my($read) = $ang/36;
  debug("$radius: $minx,$miny,$ang,$read");
}

for $i (@keys) {
#  debug("$i -> $hash{$i}");
}

# debug(%hash);

die "TESTING";

# first, 10 pixels

# TODO: combine these!
# north edge

for $i (-10..10) {
  $xpos = 43+$i;
  $ypos = 43-10;
#  debug("I: $pnm[$ypos][$xpos]");
}

# south edge
%hash = ();
for $i (-10..10) {
  $xpos = 43+$i;
  $ypos = 43+10;
  $hash{"$xpos,$ypos"} = $pnm[$ypos][$xpos];
}

@keys = sort {$hash{$a} <=> $hash{$b}} keys %hash; 

for $i (@keys) {
  debug("$i -> $hash{$i}");
}

# where x/y is 10 pixels away

# the "east edge" at 10 pixels

# debug(unfold($pnm[15]), $#pnm);

#for $j (-10..10) {
# debug("10,$j: ",$pnm[67+10][60+$j]);
#}



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

