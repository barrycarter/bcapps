#!/bin/perl

# --deps: treat dependencies as separate countries

require "/usr/local/lib/bclib.pl";

print read_file("$bclib{githome}/kmlhead.txt");

print << "MARK";
<Style id="popcenter"><IconStyle><Icon>
<href>
https://maps.gstatic.com/intl/en_us/mapfiles/markers2/measle_blue.png
</href>
</Icon></IconStyle></Style>
MARK
    ;

my($fname) = "$bclib{githome}/COW/bc-pop-centers-no-deps.csv";

if ($globopts{deps}) {$fname = "$bclib{githome}/COW/bc-pop-centers-with-deps.csv";}

for $i (split(/\n/, read_file($fname))) {

    my($cc2, $cc3, $name, $lng, $lat, $r, $pop, $npts) = split(/\,\s*/, $i);

    $pop = round($pop);

    if ($cc2 eq "CC2") {next;}

print << "MARK";
<Placemark>
<name>$name</name>
<description>Pop: $pop</description>
<styleUrl>#popcenter</styleUrl> 
<Point><coordinates>$lng,$lat,0</coordinates></Point>
</Placemark>   

MARK
;

}

print read_file("$bclib{githome}/kmlfoot.txt");

# TODO: update answer, also look for cool things like center of pop in
# other country or in water

# TODO: another verison for nondeps
