#!/bin/perl

# An unusual type of world clock
push(@INC,"/usr/local/lib");
require "bclib.pl";
chdir(tmpdir());
open(A,">clock.svg");

# Webapp...
print "Content-type: image/png\nRefresh: 60\n\n";

# zones (testing)
# Perth = Beijing = conflict
%zones = (
 "Albuquerque" => "US/Mountain",
 "Chicago" => "US/Central",
 "New York" => "US/Eastern",
 "San Francisco" => "US/Pacific",
 "GMT" => "GMT",
 "Tokyo" => "Asia/Tokyo",
 "New Delhi" => "Asia/Kolkata",
 "Sydney" => "Australia/Sydney",
# "Perth" => "Australia/Perth",
 "Athens" => "Europe/Athens",
 "Berlin" => "Europe/Berlin",
 "Beijing" => "Asia/Shanghai"
);

# IDL = international date line (of sorts)

$size = 600;

print A << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="${size}px" height="${size}px"
 viewBox="0 0 $size $size"
>
MARK
;

# the clock face numbers
for $i (0..23) {
  $an = 15*$i/180*$PI-$PI/2;
  # numbers go offedge unless I put .95 below
  $x = .95*$size/2*cos($an)+$size/2;
  $y = .95*$size/2*sin($an)+$size/2;
  print A "<text x='$x' y='$y'>$i</text>\n";
}

for $i (sort keys %zones) {
  $ENV{TZ} = $zones{$i};
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
  # angle for this time (in degrees, since this is for SVG)
  $an = ($hour*15 + $min/4 + $sec/240 - 90);
  # pad with dots based on length
  $pad= "-"x(30-length($i));
  print A "<text x='300' y='300' transform='rotate($an 300,300)' style='font-size:20'>$pad $i $min</text>\n";
}

# for $i (0..10) {
#  $an = $i*36;
#  print qq%<text x="300" y="300" transform="rotate($an 300,300)" style="font-size:25">............. $an</text>\n%;
# }

print A "</svg>\n";
close(A);

system("convert clock.svg png:-");
