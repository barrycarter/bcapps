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
  for $j (1..$ncols) {
    # get next two bytes and advance position
    $el = substr($data,$pos,2);
    debug("EL: $el");
    $pos+=2;
  }
}
