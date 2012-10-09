#!/bin/perl

# read electric meter automatically
# -orig: images are original snapshots, not trimmed for github

require "/usr/local/lib/bclib.pl";
unless ($ARGV[0]) {die "Usage: $0 file";}
$filename = $ARGV[0];
$shortfile = $filename;
$shortfile=~s/^.*\///isg;
# use filename as part of tempfiles
$tmpbase = $shortfile;

# if pulling from my original (uncropped) collection, crop
# TODO: figure out whether orig or clipped by looking at dimensions
if ($globopts{orig}) {
  system("convert -crop 448x140+191+89 -colorspace gray -rotate -5.6579 $ARGV[0] /tmp/bcer0.pnm");
} else {
  system("convert -colorspace gray -rotate -5.6579 $ARGV[0] /tmp/bcer0.pnm");
}

# for fly (TODO: newer versions of fly read PNMs?)
system("convert /tmp/bcer0.pnm /tmp/bcer0.gif");

# potential x values for centers (y value = mid of image)
# this where we start looking for brightest points

@centers=(75,159,241,321,402);

@pnm = pnm("/tmp/bcer0.pnm");

open(A,">/tmp/bcer.fly");
print A "existing /tmp/bcer0.gif\n";

# search and mark brightest point for each dial (in 5x5 "radius")
for $dial (0..4) {
  %pix = ();
  @pix = ();

  # mark where we start the search
  $xcenter = $centers[$dial];
  $ycenter = 92;

  for $i (-5..5) {
    for $j (-5..5) {
      # the x/y coords we're searching around
      $x = $centers[$dial]+$j;
      $y = 92+$i;
      # note @pix is in y,x (row, column) format
      $pix{"$x,$y"} = $pnm[$y][$x];
    }
  }
  # sort
  @pix = sort {$pix{$a} <=> $pix{$b}} keys %pix;

  # find/show lightest spot
  ($lx,$ly) = split(/\,/,$pix[-1]);
  print A "setpixel $lx,$ly,0,255,0\n";
  # TODO: seriously cleanup this code
  push(@yvals, $ly);
  push(@xvals, $lx);
}

# want to find deviation, so sort
@yvals = sort(@yvals);
$ydev = $yvals[-1]-$yvals[0];

# ydev=2 seems OK, ydev=4 excessive
# debug("YDEV: $ydev");

if ($ydev>=4) {
  debug("YDEV: $ydev >= 4");
  exit(0);
}

for $dial (0..4) {
  for $radius (10..30) {
#    debug("SENDING: $xvals[$dial],$yvals[$dial]");
    $ret = reading($radius,$xvals[$dial],$yvals[$dial]);

    # compute which of 10 numbers this mean (ignoring reversals for now)
    # always read toward lower number, not closest number
    # 0 -> 7.5, so -18-+18 -> 7, +18-+54 -> 8, and so on
    $read = int(fmodp(($ret-18)/36+8,10));
    $count[$dial]{$read}++;

    # angles for this dial (returned clockwise starting at "7.5")
    $angs[$dial][$radius] = $ret;
  }
}

for $dial (0..4) {
  %counts = %{$count[$dial]};
  # sort the counts for this dial
  @counts = sort {$counts{$b} <=> $counts{$a}} keys %counts;

  # for dials 1 + 3, read in reverse (so 1 becomes 8 [not 9])
  if ($dial%2) {$counts[0] = 9 - $counts[0];}

  debug("DIAL: $dial, READING: $counts[0]");
  push(@reading, $counts[0]);
}

close(A);
system("fly -q -i /tmp/bcer.fly -o /tmp/bcer2.gif");
# system("cp /tmp/bcer2.gif $tmpbase.gif");
# system("display $tmpbase.gif &");

$reading = join("",@reading);
print "$tmpbase: $reading\n";

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

=item reading($r,$cx,$cy,$options)

Find the "best reading" at rectangular radius $r from $cx,$cy

$options currently unused

=cut

sub reading {
  my($r,$cx,$cy,$options) = @_;
  my(%hash);

  # for each value of x (within $r), determine y values w distance $r
  for $i (-$r..$r) {
    # we want to find y such that ($r-.5)^2 <= $y^2+$i^2 <= (r+.5)^2
    my($max) = floor(sqrt(($r+.5)**2-$i**2));
    my($min) = ceil((abs($r-.5)>abs($i))?(sqrt(($r-.5)**2-$i**2)):0);

    for $k (-1,1) {
      for $j ($min..$max) {
	my($x,$y) = ($cx+$i,$cy+$j*$k);
	# pnm is in row/col order
	$hash{"$x,$y"} = $pnm[$y][$x];
      }
    }
  }

  # find the darkest point(s)
  my(@keys) = sort {$hash{$a} <=> $hash{$b}} keys %hash;

  # find angle of darkest point from center (and lightest)
  my($dx,$dy) = split(/\,/, $keys[0]);
  my($lx,$ly) = split(/\,/, $keys[-1]);

  # and print to fly
  print A "setpixel $dx,$dy,255,0,0\n";
#  print A "setpixel $lx,$ly,0,0,255\n";

#  debug("DARK($dial,$r): $dx-$cx,$dy-$cy");
  # this is a 90 degree right rotate so 0 meter = 0 degrees

  # return just the angle
#  debug("ATAN: $cy-$dy, $cx-$dx");
  my($an) = atan2($cy-$dy,$cx-$dx)*$RADDEG;
#  debug("GOT: $an");
  return $an;
}

=item sqrt2($x)

Returns the square root of $x if $x>0, 0 otherwise

=cut

sub sqrt2 {
  my($x) = @_;
  if ($x<=0) {return 0;}
  return sqrt($x);
}
