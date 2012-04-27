#!/bin/perl

# Reads 63384828.bil to find where ABQ is exactly one mile high

# Probably has no use whatsoever to anyone else

push(@INC,"/usr/local/lib");
chdir("/home/barrycarter/BCGIT/");
require "bclib.pl";

$data = read_file("db/63384828.bil");

# from db/63384828.hdr (selected info)
$nrows = 3251;
$ncols = 5714;
$ulxmap = -106.640385801789;
$ulymap = 35.138472222782;
# in degrees; this is a 1/9-arcsec map
$xdim = 3.08641975309902e-005;
$ydim = 3.08641975309902e-005;

for $i (1..$nrows) {

  # there are "too many" points w/ elevation 1 mile (1609m), so we find the median one for each row
  @milehigh = ();


  for $j (1..$ncols) {
    # get next two bytes and advance position
    $el1 = ord(substr($data,$pos,1));
    $el2 = ord(substr($data,$pos+1,1));
    $pos+=2;
    # LSB
    $el = 256*$el2+$el1;

    # TODO: below is a cheat, in theory, adjacent tiles could skip this value
    # 1609.344m = 5280ft = 1 mile
    unless ($el == 1609) {next;}

    # middle of tile
    $lon = $ulxmap + $xdim*($j-.5);
    # note that latitudes DECREASE as y increases
    $lat = $ulymap - $ydim*($i-.5);

    push(@milehigh, $lon);
  }

  # @milehigh is necessarily in order (since we're going
  # left-to-right), so median is (to trivial error)
  $medlon = $milehigh[$#milehigh/2];
  debug("$lat: $medlon");
}

# TODO: KMLify

