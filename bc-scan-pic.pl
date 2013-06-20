#!/bin/perl

# quick and dirty wrapper to scanimage: takes a 300 dpi full page scan
# and outputs it to a unique file in the current directory

my($date) = `date +%Y%M%d.%H%M%S.%N`;
chomp($date);
system("sudo scanimage --resolution 600 > $date.ppm");
print "SCAN COMPLETE, CONVERTING\n";
system("convert $date.ppm $date.jpg");
