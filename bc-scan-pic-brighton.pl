#!/bin/perl

# trivial version of bc-scan-pic.pl for brighton, which has a single
# fixed scanner

require "/usr/local/lib/bclib.pl";

# scanning takes a while, so default alert me when done
defaults("xmessage=1");

my($scanner) = "pixma:04A9176D_C4363E";
my($date) = `date +%Y%m%d.%H%M%S.%N`;
chomp($date);
system("sudo scanimage --mode Color -d $scanner --resolution 600 > $date.ppm");
# system("sudo scanimage -d $scanner --resolution 300 > $date.ppm");
system("convert $date.ppm $date.jpg");
print "SCAN COMPLETE, see $date.ppm, $date.jpg\n";
