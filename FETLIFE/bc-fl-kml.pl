#!/bin/perl

# Creates a KML file with FetLifers locations (probably won't work,
# too many markers, fallback is bc-fl-map.pl

require "/usr/local/lib/bclib.pl";

my($row,%data);

while (<>) {

  # new row
  if (/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; next;}

  unless (/^\s*(.*?):\s*(.*)/) {warn("IGNORING: $_"); next;}

  $data{$row}{$1}=$2;
}

print << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>
MARK
;

for $i (keys %data) {
  my(%hash) = %{$data{$i}};
  print << "MARK";
<Placemark>
<name>$hash{city}</name>
<Point>
<coordinates>$hash{longitude},$hash{latitude}</coordinates>
</Point>
</Placemark>
MARK
;
}

print "\n</Document></kml>\n";

