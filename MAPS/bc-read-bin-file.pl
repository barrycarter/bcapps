#!/bin/perl

# TODO: this is specific to popcount, maybe generalize?

require "/usr/local/lib/bclib.pl";

my(%hash);

# $hash{lng} = 0;
# $hash{lat} = 0;

# debug(lngLat2popcount(\%hash));

# die "TESTING";

print << "MARK";
new
size 1024,768
setpixel 0,0,0,0,0

MARK
    ;



for $x (1..1024) {
    for $y (1..768) {
	$hash{lng} = 360/1024*$x - 180;
	$hash{lat} = 90 - 180/768*$y;
	my($val) = lngLat2popcount(\%hash);

	my($shade) = round($val/32*255/16)*16;
	if ($shade > 255) {$shade = 255;}

	if ($val == -9999) {
	    print "setpixel $x,$y,0,0,255\n";
#	} elsif ($val > 10) {
#	    print "setpixel $x,$y,255,0,0\n";
#	} elsif ($val > 0) {
#	    print "setpixel $x,$y,128,0,0\n";
	} else {
	    print "setpixel $x,$y,$shade,0,0\n";
	}
    }
}

die "TESTING";

for $i (1..200) {
    $hash{lng} = rand()*360 - 180;
    $hash{lat} = rand()*180 - 90;
#    debug($hash{lng}, $hash{lat});
    debug(lngLat2byte(\%hash));
}

sub lngLat2popcount {

    # if file not already open, open it

    unless (-r POPCOUNT) {
	open(POPCOUNT, "/mnt/popcount/gpw_v4_population_count_rev11_2020_30_sec_1.all.bin");
    }

    my(%hash) = %{$_[0]};

    # TODO: don't hardcode these values

    my($ilng) = round($hash{lng}*120);
    my($ilat) = round($hash{lat}*120);

    # chunk numbers are 0 through 7
    my($chunk) = 2+floor($ilng/10800);
    if ($ilat < 0) {$chunk += 4;}

    # where in chunk is data?

    my($row) = 10800-$ilat%10800;
    my($col) = $ilng%10800;

    my($byte) = ($chunk*10800**2 + $row*10800 + $col)*8;

    debug("$hash{lng}, $hash{lat} -> $chunk, $row, $col -> $byte");

    seek(POPCOUNT, $byte, SEEK_SET);

    my($data);
    sysread(POPCOUNT, $data, 8);

#    debug("BYTE: $byte, DATA: $data");

    return(unpack("d", $data));
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
