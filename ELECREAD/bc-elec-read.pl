#!/bin/perl

# read electric meter automatically
# -orig: images are original snapshots, not trimmed for github

require "/usr/local/lib/bclib.pl";
unless ($ARGV[0]) {die "Usage: $0 file";}
debug("FILENAME: $ARGV[0]");

# straighten image and then slice into 5 dials
# if pulling from my original (uncropped) collection, also crop
if ($globopts{orig}) {
  system("convert -crop 448x140+191+89 -rotate -5.6579 $ARGV[0] /tmp/bcer0.pnm");
} else {
  system("convert -rotate -5.6579 $ARGV[0] /tmp/bcer0.pnm");
}

system("convert -colorspace gray /tmp/bcer0.pnm /tmp/bcer1.pnm");
system("convert -colorspace gray /tmp/bcer0.pnm /tmp/bcer0.gif");

# potential x values for centers (y value = mid of image)

@centers=(75,159,241,321,402);

@pnm = pnm("/tmp/bcer1.pnm");

open(A,">/tmp/bcer.fly");
print A "existing /tmp/bcer0.gif\n";

# search and mark brightest point for each dial (in 5x5 "radius")
for $dial (0..4) {
  %pix = ();
  @pix = ();

  # mark where we start the search
  $xcenter = $centers[$dial];
  $ycenter = 92;
#  print A "setpixel $centers[$dial],92,255,0,0\n";

  for $i (-5..5) {
    for $j (-5..5) {
      # the x/y coords we're searching around
      $x = $centers[$dial]+$j;
      $y = 92+$i;
      # note y,x format
      $pix{"$x,$y"} = $pnm[$y][$x];
#      $pix{"$i,$j"} = $pnm[92+$i][$centers[$dial]+$j];
    }
  }
  # sort
  @pix = sort {$pix{$a} <=> $pix{$b}} keys %pix;
  debug("DIAL: $dial");

  # find/show lightest spot
  ($lx,$ly) = split(/\,/,$pix[-1]);
  print A "setpixel $lx,$ly,0,255,0\n";
  # TODO: seriously cleanup this code
  push(@yvals, $ly);
  push(@xvals, $lx);
#  debug("LXLY: $lx, $ly");

  for $k (@pix) {
#    debug("$k -> $pix{$k}");
  }
}

# want to find deviation, so sort
@yvals = sort(@yvals);
$ydev = $yvals[-1]-$yvals[0];

# ydev=2 seems OK, ydev=4 excessive
debug("YDEV: $ydev");

if ($ydev>=4) {exit(0);}

for $dial (0..4) {
  for $radius (10..30) {
    $ret = reading($radius,$xvals[$dial],$yvals[$dial]);
    debug("DIAL: $dial, RADIUS: $radius, ANGLE: $ret");
  }
}

close(A);
system("fly -q -i /tmp/bcer.fly -o /tmp/bcer2.gif");
system("display /tmp/bcer2.gif&");

die "TESTING";

# general idea is to read circles radiating out from center points and
# find "darkest point" for each dial

# dial centers
%centers =(0 => "40,38", 1 => "41,38", 2 => "42,38", 3=> "41,37", 4=> "39,37");

# and again?
@centers = ("39,34", "40,34", "40,34", "39,33", "34,32");

for $dial (0..4) {
  # left of circle
  my($pos) = 72+82*$dial-80/2;
  # ypos is fixed at 97-83/2 (assuming true circles)
  system("convert -colorspace gray -crop 83x83+$pos+55 /tmp/bcer0.pnm /tmp/bcer2-$dial.pnm");

  @pnm = pnm("/tmp/bcer2-$dial.pnm");
  %count = ();

# use fly to show how this program "thinks"
system("convert /tmp/bcer2-$dial.pnm /tmp/bcer2-$dial.gif");
open(A,">/tmp/bcer2-$dial.fly");
print A "existing /tmp/bcer2-$dial.gif\n";

# for each radius
# for $radius (12..17) {
  for $radius (0..50) {
  my($read) = reading($radius);
  $count{floor($read)}++;
  debug("$dial/$radius: $read");
}

  debug("COUNTHAS",%count);
  @counts = sort {$count{$b} <=> $count{$a}} keys %count;
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

#  for $i (@keys) {
#    debug("DIAL $dial, RADIUS: $r, KEY: $i -> $hash{$i}");
#  }

  # find angle of darkest point from center (and lightest)
  my($dx,$dy) = split(/\,/, $keys[0]);
  my($lx,$ly) = split(/\,/, $keys[-1]);

  # and print to fly
  print A "setpixel $dx,$dy,255,0,0\n";
#  print A "setpixel $lx,$ly,0,0,255\n";

  debug("DARK($dial,$r): $dx-$cx,$dy-$cy");
  # this is a 90 degree right rotate so 0 meter = 0 degrees

  # return just the angle
  my($an) = fmodp((atan2($cy-$dy,$dx-$cx)-$PI/2)*$RADDEG,360);
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
