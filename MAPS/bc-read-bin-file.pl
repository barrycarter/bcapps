#!/bin/perl

# TODO: this is specific to popcount, maybe generalize?

require "/usr/local/lib/bclib.pl";

my(%hash);

for $i (1..200) {
    $hash{lng} = rand()*360 - 180;
    $hash{lat} = rand()*180 - 90;
    debug($hash{lng}, $hash{lat});
    lngLat2byte(\%hash);
}

sub lngLat2byte {

    my(%hash) = %{$_[0]};

    # TODO: watch out for corner cases, including 0 lat and +-180 lng
    # (also maybe +- 90 lat)

    # $hash{lng}/90 between -2, -1, 0, 1

    my($chunk) = 3+floor($hash{lng}/90)+$hash{lat}>0?4:0;

    debug($chunk);
}



=item format

below is lower left corner in lng, lat form

1: -180, 0
2: -90, 0
3: 0, 0
4: 90, 0
5: -180, -90
6: -90, -90
7: 0, -90
8: 90, -90

=cut
