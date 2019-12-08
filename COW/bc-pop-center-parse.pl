#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($dir) = "$bclib{githome}/COW/";

my($data) = read_file("$dir/bc-pop-center-output.txt");

# load CC2 to CC3 conversions and back

my(%cc223, %cc322);

for $i (split(/\n/, read_file("$dir/bc-cc2cc3.csv"))) {

    my($name, $cc2, $cc3, $ccnum) = csv($i);
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

    $i=~s/^\s*(\S+?)\s+\(\S+\)\s+\=\s+(.*?)$//;

    $chash{$country}{$1} = $2;

}

print "CC2,CC3,Name,clng,clat,r_value,MEANUNITKM\n";

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

    unless ($cc322{$cinfo{ISOCODE}}) {$cc322{$cinfo{ISOCODE}} = "N/A";}

    print "$cc322{$cinfo{ISOCODE}},$cinfo{ISOCODE},$cinfo{NAME0},$lng,$lat,$r,$cinfo{MEANUNITKM}\n"

}
