#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($dir) = "$bclib{githome}/COW/";

my($data) = read_file("$dir/bc-pop-center-output.txt");

# load CC2 to CC3 conversions and back

my(%cc223, %cc322);

for $i (split(/\n/, read_file("$dir/bc-cc2cc3.csv"))) {

    $i=~/^(.*?),([A-Z]+),([A-Z]+),(\d+)$/;

    my($name, $cc2, $cc3, $ccnum) = ($1, $2, $3, $4);

    $cc223{$cc2} = $cc3;
    $cc322{$cc3} = $cc2;
}

# load dependent data from dependentcountries_territories.csv

my(%conversions);

for $i (split(/\n/, read_file("$dir/dependentcountries_territories.csv"))) {

  my($iso, $name, $admin0) = csv($i);

  $conversions{$iso} = $admin0;

}

# the file bc-gpw-natl-grid.txt is the output of:

# ogrinfo -al /home/user/20191204/gpw_v4_national_identifier_grid_rev11_30_sec.shp | fgrep -v POLYGON|");

# which gives meta information about countries without polygon information

my(%chash);
my($country) = 0;

for $i (split(/\n/, read_file("$dir/bc-gpw-natl-grid.txt"))) {

    if ($i=~/^\s*$/) {next;}

    if ($i=~s/Value\s*\(Integer\)\s*\= (\d+)//) {
	$country = $1;
	next;
    }

    while ($i=~s/^\s*(\S+?)\s+\(\S+\)\s+\=\s+(.*?)$//) {$chash{$country}{$1} = $2;}
}

# debug("ETA", $chash{100}{ISOCODE}, $chash{100}{NAME0});

print "CC2,CC3,Name,clng,clat,r_value,MEANUNITKM\n";

my(%cinfo);

for $i (split(/\n/, $data)) {

    my(%hash);

    while ($i=~s/([a-z]+): ([\d\.\-]+)//i) {$hash{$1} = $2;}

    my($country) = $chash{$hash{cc}}{ISOCODE};

    my($name) = $chash{$hash{cc}}{NAME0};
    debug("$i -> $name");

#    $cinfo{$country}{CC3} = $country;
		       
    if ($cc322{$country}) {$country = $cc322{$country};}
    
    if ($conversions{$country}) {
	debug("DESTROYING NAME FOR: $country -> $conversions{$country}");
	$country = $conversions{$country};
	$name ="";
    }

    debug("ASSIGNING $country name to $name");
    if ($name) {$cinfo{$country}{name} = $name;}

#    debug("$hash{cc} -> $country");

    # add values for country + all deps
    for $j ("x", "y", "z", "pop", "points", "parea") {
	$cinfo{$country}{$j} += $hash{$j};
    }
}

for $i (sort keys %cinfo) {

    debug("IBETA: $i");

#    debug("I: $i", "HASH", keys %{$cinfo{$i}});

#    debug("ALPHA", "$i, $cinfo{$i}{CC3}");

#    next; # TESTING

    my($avgx) = $cinfo{$i}{x}/$cinfo{$i}{pop};
    my($avgy) = $cinfo{$i}{y}/$cinfo{$i}{pop};
    my($avgz) = $cinfo{$i}{z}/$cinfo{$i}{pop};

    my($lng, $lat, $r) = xyz2sph($avgx, $avgy, $avgz);

    $lng *= $RADDEG;
    $lat *= $RADDEG;

    if ($lng>180) {$lng-=360;}

    unless ($cc223{$i}) {$cc223{$i} = "N/A";}

    print "$i,$cc223{$i},$cinfo{$i}{name},$lng,$lat,$r,$cinfo{MEANUNITKM}\n";

}

=item comment


    %cinfo = %{$chash{$hash{cc}}};

    unless ($cc322{$cinfo{ISOCODE}}) {$cc322{$cinfo{ISOCODE}} = "N/A";}

    print "$cc322{$cinfo{ISOCODE}},$cinfo{ISOCODE},$cinfo{NAME0},$lng,$lat,$r,$cinfo{MEANUNITKM}\n"

}

=cut
