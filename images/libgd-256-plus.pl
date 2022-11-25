#!/usr/bin/perl

# tests 256+ color PNG images

use GD;
require "/usr/local/lib/bclib.pl";

GD::Image->trueColor(1);

my($im) = new GD::Image(256,256);

for $i (0..255) {
  for $j (0..255) {
    my($r) = int(rand()*256);
    my($g) = int(rand()*256);
    my($b) = int(rand()*256);
    my($col) = $im->colorAllocate($r,$g,$b);
    $im->setPixel($i, $j, $col);
  }
}

write_file($im->png, "/tmp/temp.png");

