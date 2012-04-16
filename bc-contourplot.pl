#!/bin/perl

# Uses Mathematica's "contourplot" function to display temperatures,
# not voronoi

push(@INC,"/usr/local/lib");
require "bclib.pl";

# below copied from bc-generic-voronoi

open(A,"egrep '^KNM' db/wstations.txt|");

while (<A>) {
  chomp;

  # ok, if it's less than five minutes old...
  if (-f ("/tmp/pws-$_.xml") && (-M ("/tmp/pws-$_.xml") < 300/86400)) {next;}

  # TODO: hardcoding filenames here is bad, but can't use
  # cache_command, since I'm using parallel
  push(@cmd, "curl -s -o /tmp/pws-$_.xml 'http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=$_'");
}

close(A);
write_file(join("\n",@cmd)."\n", "/tmp/pws-suck.sh");
system("parallel < /tmp/pws-suck.sh");

print "temps={\n";

for $i (glob("/tmp/pws-*.xml")) {
  $data = read_file($i);

  # fill hash with data
  $hashref = {};
  while ($data=~s%<(.*?)>(.*?)</\1>%%) {$$hashref{$1}=$2};

  # ignore those sans station_id
  unless ($$hashref{station_id}) {next;}

  # ignore temps over 139F
  if ($$hashref{temp_f} > 139) {next;}

  print "{$$hashref{longitude}, $$hashref{latitude}, $$hashref{temp_f}},\n";
}

print "}\ntemps=Drop[temps,-1];\n";

