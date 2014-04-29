#!/bin/perl

# quick and dirty wrapper to scanimage: takes a 300 dpi full page scan
# and outputs it to a unique file in the current directory

require "/usr/local/lib/bclib.pl";

# find USB address of my ADF scanner
%scanners = %{find_attached_scanners()};
# must quote these strings, otherwise interpreted as numbers
$usb = $scanners{"0x03f0"}{"0x1205"};
unless ($usb) {die "Scanner not attached";}
$scanner = "hp5590:$usb";

my($date) = `date +%Y%m%d.%H%M%S.%N`;
chomp($date);
system("sudo scanimage --mode Color -d $scanner --resolution 600 > $date.ppm");
# system("sudo scanimage -d $scanner --resolution 300 > $date.ppm");
print "SCAN COMPLETE, CONVERTING\n";
system("convert $date.ppm $date.jpg");
