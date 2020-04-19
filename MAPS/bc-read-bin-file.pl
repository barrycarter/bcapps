#!/bin/perl

# TODO: this is specific to popcount, maybe generalize?

require "/usr/local/lib/bclib.pl";

my(%hash);

for $i (1..200) {
    $hash{lng} = rand()*360 - 180;
    $hash{lat} = rand()*180 - 90;
#    debug($hash{lng}, $hash{lat});
    debug(lngLat2byte(\%hash));
}

sub lngLat2byte {

    # if file not already open, open it

    unless (-r POPCOUNT) {
	open(POPCOUNT, "/mnt/popcount/gpw_v4_population_count_rev11_2020_30_sec_1.all.bin")||die("ERROR: $!");
    }

    my(%hash) = %{$_[0]};

    # TODO: don't hardcode these values

    my($ilng) = round($hash{lng}*120);
    my($ilat) = round($hash{lat}*120);

    # chunk numbers are 0 through 7
    my($chunk) = 2+floor($ilng/10800);
    if ($ilat < 0) {$chunk += 4;}

    # where in chunk is data?

    my($row) = $ilat%10800;
    my($col) = $ilng%10800;

    my($byte) = ($chunk*116640000 + $row*10800 + $col)*8;

    seek(POPCOUNT, $byte, SEEK_SET);
    debug("ERROR: $!");

    my($data);
    sysread(POPCOUNT, $data, 8);

    debug("BYTE: $byte, DATA: $data");

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
