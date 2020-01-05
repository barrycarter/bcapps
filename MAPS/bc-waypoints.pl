#!/bin/perl

require "/usr/local/lib/bclib.pl";

my $data = `bzcat $bclib{githome}/MAPS/NfdcFacilities.xls.bz2`;
my(@data) = split(/\r\n/, $data);

my(@ndata);

for $i (@data) {
    my(@l) = split(/\t/, $i);
    push(@ndata, \@l);
}

my($arrref, $hashref) = arraywheaders2hashlist(\@ndata);


# debug($ndata[17][4]);

# @ndata = map($_ = \@{split(/\t/, $_)}, @data);

# debug(@{$ndata[111]});

# die "TESTING";

# ARPLatitude ARPLongitude IcaoIdentifier SiteNumber NOTAMFacilityID FacilityName

# confirmed SiteNumber exists uniquely for each row

my(%faainfo);

for $i (@{$arrref}) {

    my($key) = $i->{'"SiteNumber"'};

    for $j ("ARPLatitude", "ARPLongitude", "IcaoIdentifier", "NOTAMFacilityID", "FacilityName") {
	$faainfo{$key}{$j} = $i->{"\"$j\""};
    }

#    debug("HASH", %{$faainfo{$key}});

    # parse latitude
    $faainfo{$key}{ARPLatitude} =~m%^(\d+)\-(\d+)\-([\d\.]+)(S|N)$% || die("BAD LAT: $faainfo{$key}{ARPLatitude}");
    my($d, $m, $s, $ns) = ($1, $2, $3, $4);
    $faainfo{$key}{lat} = $d + $m/60 + $s/3600;
    if ($ns=~/^s/i) {$faainfo{$key}{lat} *= -1;}

    # parse longitude
    $faainfo{$key}{ARPLongitude} =~m%^(\d+)\-(\d+)\-([\d\.]+)(E|W)$% || die("BAD LNG: $faainfo{$key}{ARPLatitude}");
    my($d, $m, $s, $ns) = ($1, $2, $3, $4);
    $faainfo{$key}{lng} = $d + $m/60 + $s/3600;
     if ($ns=~/^w/i) {$faainfo{$key}{lng} *= -1;}

#    debug("VALS", $faainfo{$key}{lat}, $faainfo{$key}{lng});
}

# debug(keys %faainfo);

$p1 = "04740.1*H";
$p2 = "27041.*A";

debug($faainfo{$p1}{lng}, $faainfo{$p1}{lat}, $faainfo{$p2}{lng}, $faainfo{$p2}{lat});

debug(gcstats($faainfo{$p1}{lat}, $faainfo{$p1}{lng}, $faainfo{$p2}{lat}, $faainfo{$p2}{lng}, 0.1));

# TODO: allow reference by IcaoIdentifier, etc
