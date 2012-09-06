#!/bin/perl

# read electric meter automatically

require "/usr/local/lib/bclib.pl";

# these are roughly the 5 center points of the dials in any image

# 67,60
# 149,68
# 232,77
# 314,85
# 390,92

# general idea is to read circles radiating out from center points and
# find "darkest point" for each dial

# This is for testing only
system("convert 20120617.173402.jpg /tmp/bcer1.png");
debug(unfold(pnm("/tmp/bcer1.png")));

=item pnm($file)

Given a PNM format graphic $file, return array of pixels

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

