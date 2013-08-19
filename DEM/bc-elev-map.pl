#!/bin/perl

# Reads 63384828.bil to create an elevation map for the ABQ area

# elevation range: 1505-2486

require "/usr/local/lib/bclib.pl";

$data = read_file("../db/63384828.bil");

# from db/63384828.hdr (selected info)
$nrows = 3251;
$ncols = 5714;
$ulxmap = -106.640385801789;
$ulymap = 35.138472222782;
# in degrees; this is a 1/9-arcsec map
$xdim = 3.08641975309902e-005;
$ydim = 3.08641975309902e-005;

print "new\nsize 5714,3251\n";

for $i (1..$nrows) {
  for $j (1..$ncols) {
    # get next two bytes and advance position
    $el1 = ord(substr($data,$pos,1));
    $el2 = ord(substr($data,$pos+1,1));
    $pos+=2;
    # LSB
    $el = 256*$el2+$el1;
    # "heat" map using hues
    my($rgb) = hsv2rgb(($el-1505)/981,1,1,"format=decimal");
    print "setpixel $j,$i,$rgb\n";
  }
}


