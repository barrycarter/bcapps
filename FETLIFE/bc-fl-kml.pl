#!/bin/perl

# Creates a KML file with FetLifers locations (probably won't work,
# too many markers, fallback is bc-fl-map.pl

# --clientside: create a clientside map (not yet working 100%)

require "/usr/local/lib/bclib.pl";

my($row,%data);

while (<>) {

  # new row
  if (/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; next;}

  unless (/^\s*(.*?):\s*(.*)/) {warn("IGNORING: $_"); next;}

  $data{$row}{$1}=$2;
}

if ($globopts{clientside}) {
  print read_file("$bclib{githome}/gbefore.txt");
} else {
print << "MARK";
<?xml version="1.0" encoding="utf-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
<Document>

<Style id="pushpin">
 <IconStyle id="mystyle">
   <Icon>
     <href>http://test.94y.info/dotfl.png</href>
     <scale>1.0</scale>
   </Icon>
 </IconStyle>
</Style>

MARK
;
}


for $i (keys %data) {
  my(%hash) = %{$data{$i}};

  # client side
  if ($globopts{clientside}) {
    print << "MARK";
new google.maps.Marker({
 position: new google.maps.LatLng($hash{latitude},$hash{longitude}),
 map: map, 
 icon:"http://test.bcinfo3.barrycarter.info/dotfl.png",
 title:"$hash{city}"
});
MARK
;
} else {
  print << "MARK";
<Placemark>
<name>$hash{city}</name>
<styleUrl>#pushpin</styleUrl>
<Point>
<coordinates>$hash{longitude},$hash{latitude}</coordinates>
</Point>
</Placemark>
MARK
;
}
}

if ($globopts{clientside}) {
print read_file("$bclib{githome}/gend.txt");
} else {
print "\n</Document></kml>\n";
}


