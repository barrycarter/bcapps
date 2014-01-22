#!/bin/perl

# quick and dirty wrapper to scanimage: takes a 300 dpi full page scan
# and outputs it to a unique file in the current directory

# $scanner = "hp5590:libusb:002:006";
# $scanner = "hp5590:libusb:001:003";
# $scanner = "hpaio:libusb:001:004";
$scanner = "hp5590:libusb:001:004";
my($date) = `date +%Y%m%d.%H%M%S.%N`;
chomp($date);
# system("sudo scanimage --mode Color -d $scanner --resolution 600 > $date.ppm");
system("sudo scanimage -d $scanner --resolution 300 > $date.ppm");
print "SCAN COMPLETE, CONVERTING\n";
system("convert $date.ppm $date.jpg");
