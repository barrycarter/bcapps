#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

# load dependent data from dependentcountries_territories.csv

my(%conversions);

for $i (split(/\n/, read_file("$bclib{githome}/COW/dependentcountries_territories.csv"))) {

  my($iso, $name, $admin0) = csv($i);

  $conversions{$iso} = $admin0;

}

# grab natgrid data

open(A, "ogrinfo -al /home/user/20191204/gpw_v4_national_identifier_grid_rev11_30_sec.shp | fgrep -v POLYGON|");

my(%chash);
my($country) = 0;

while (<A>) {

    if (/^\s*$/) {next;}

    if (s/Value\s*\(Integer\)\s*\= (\d+)//) {
	$country = $1;
	next;
    }

    s/^\s*(\S+?)\s+\(\S+\)\s+\=\s+(.*?)$//;

    $chash{$country}{$1} = $2;

}

# debug("KEYS", keys %chash);

for $i (split(/\n/, $data)) {

    my(%hash);

    while ($i=~s/([a-z]+): ([\d\.\-]+)//i) {$hash{$1} = $2;}

    my($avgx) = $hash{x}/$hash{pop};
    my($avgy) = $hash{y}/$hash{pop};
    my($avgz) = $hash{z}/$hash{pop};

    my($lng, $lat, $r) = xyz2sph($avgx, $avgy, $avgz);

    $lng *= $RADDEG;
    $lat *= $RADDEG;

    if ($lng>180) {$lng-=360;}

    %cinfo = %{$chash{$hash{cc}}};

    print "$cinfo{ISOCODE},$cinfo{NAME0},$lng,$lat,$r,$cinfo{MEANUNITKM}\n"

}




