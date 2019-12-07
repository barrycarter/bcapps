#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

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


#    debug("OSM($hash{cc}): $lat,$lng");
#    debug("$hash{cc}/$lng,$lat/$r");

    for $j ("x", "y", "z") {$hash{"avg$j"} = $hash{$j}/$hash{pop};}

    @{$hash{sph}} = xyz2sph($hash{avgx}, $hash{avgy}, $hash{avgz});

    $hash{lng} = @{$hash{sph}}[0]*$RAD2DEG;
    $hash{lat} = @{$hash{sph}}[1]*$RAD2DEG;
    $hash{r} = $hash{sph}[2];

    debug($hash{cc}, unfold($chash{$hash{cc}}));

#    debug("$hash{cc}, $hash{lng}, $hash{lat}, $hash{r}");
#    debug(%hash);

#    debug("I: $i");

}






