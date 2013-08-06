#!/bin/perl

# scans images using my ADF scanner

require "/usr/local/lib/bclib.pl";

for (;;) {
  # no actual caching, since each image is different
  my($date) = `date +%Y%m%d.%H%M%S.%N`;
  chomp($date);
  my($cmd) = qq%sudo scanimage -d 'hp5590:libusb:001:004' --source "ADF Duplex" --resolution 600 > $date.ppm%;
  debug("CMD: $cmd");
  my($out,$err,$res) = cache_command2($cmd);
  debug("OUT: $out/$err/$res");
}

