#!/bin/perl

# how fast is seeking within a squashfs file?

require "/usr/local/lib/bclib.pl";

# this is a 100GB file uncompressed

open(A, "/mnt/kemptown/tmp/mt/gaia2-extracted-sorted.csv");

# pretending it's a 3 arcsecond file

my($lat) = 35;
my($lng) = -106.5;

my($buf);

# this is indeed very quick

for $i (0..255) {
  for $j (0..255) {
    
    my($lt) = $lat+3*$i/3600;
    my($ln) = $lng+3*$j/3600;

    my($byte) = ($lt+90)*432000 + ($ln+180)*60*20;

    debug("BYTE: $byte");

    sysseek(A, $byte, SEEK_SET);
    sysread(A,$buf,1);
    debug("BUF: $buf");
  }
}
