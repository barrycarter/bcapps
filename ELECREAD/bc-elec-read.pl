#!/bin/perl

# read electric meter automatically
# -orig: images are original snapshots, not trimmed for github

require "/usr/local/lib/bclib.pl";

# these are roughly the 5 center points of the dials in any image
# images are 448x140

# 67,60; 149,68; 232,77; 314,85; 390,92

# center position after rotation of -5.6579 degs

# 72,97
# 155, 97 (83px shift)
# 238,97 (83px shift)
# 320,97 (82px shift) [321 works pretty well too]
# 399,97 (79px shift) [400 works, but 403 does not]

# even at radius 18, bumping into numbers
# at radius 11, hitting "bulby" part of needle

# straighten image and then slice into 5 dials
unless ($ARGV[0]) {die "Usage: $0 file";}


# if pulling from my original (uncropped) collection, also crop

if ($globopts{orig}) {
  system("convert -crop 448x140+191+89 -rotate -5.6579 $ARGV[0] /tmp/bcer0.pnm");
} else {
  system("convert -rotate -5.6579 $ARGV[0] /tmp/bcer0.pnm");
}


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

for $dial (0..4) {
  @pnm = pnm("/tmp/bcer2-$dial.pnm");
  %count = ();

# for each radius

for $radius (12..17) {
  my($read) = reading($radius);
  $count{floor($read)}++;
  debug("$dial/$radius: $read");
}

  debug("COUNTHAS",%count);
  @counts = sort {$count{$b} <=> $count{$a}} keys %count;

  if ($dial%2) {$counts[0] = fmodp(-$counts[0],10);}
  
  push(@out,$counts[0]);

  debug("COUNT: $counts[0]");

}

print "$ARGV[0]: ".join("",@out)."\n";

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

=item reading($r,$options)

Find the "best reading" at radius $r (uses global variables;
app-specific subroutine). Returns a decimal since that might be
helpful w other dial reading.

$options currently unused

=cut

sub reading {
  my($r,$options) = @_;
  my(%hash);

  # for each value of x (within $r), determine y values w distance $r
  for $i (-$r..$r) {
    # we want to find y such that ($r-.5)^2 <= $y^2+$i^2 <= (r+.5)^2
    my($max) = floor(sqrt(($r+.5)**2-$i**2));
    my($min) = ceil((abs($r-.5)>abs($i))?(sqrt(($r-.5)**2-$i**2)):0);

    for $j ($min..$max) {
      # using 43,43 as center = bad?
      my($x,$y) = (43+$i,43+$j);
      # pnm is in row/col order
      $hash{"$x,$y"} = $pnm[$y][$x];
    }
  }

  # find the darkest point(s)
  my(@keys) = sort {$hash{$a} <=> $hash{$b}} keys %hash;

  # find angle of darkest point from 43,43
  ($dx,$dy) = split(/\,/, $keys[0]);
  debug("DARK($dial,$r): $dx,$dy");
  # this is a 90 degree right rotate so 0 meter = 0 degrees
  my($an) = fmodp(atan2($dx-43, 43-$dy)*$RADDEG,360);
  my($read) = $an/36;
  debug("ANGLE/READ($dial,$r): $an/$read");
  return $read;

}

=item sqrt2($x)

Returns the square root of $x if $x>0, 0 otherwise

=cut

sub sqrt2 {
  my($x) = @_;
  if ($x<=0) {return 0;}
  return sqrt($x);
}
