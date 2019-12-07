#!/bin/perl

require "/usr/local/lib/bclib.pl";

open(A, "/home/user/20191204/popcount.ehdr");
open(B, "/home/user/20191204/natgrid.ehdr");

my($bsize) = 2;

# <h>tis of thee...</h>
my(%country);

for ($i=0; $i < 43200*21600; $i++) {

# for ($k=0; $k < 1000000; $k++) {

#    $i = round(rand()*43200*21600);

    if ($i%10**6==0) {debug("I: $i");}

    my($abuf, $bbuf);

    my($aerr) = seek(A, 4*$i, SEEK_SET);
    if ($aerr != 1) {die("BAD SEEK: $!");}
    my($aread) = read(A, $abuf, 4);
    if ($aread != 4) {die("READ ERROR: $!");}
    my($aval) = str2float($abuf);

    if ($aval < 1e-38) {next;}

    my($berr) = seek(B, $bsize*$i, SEEK_SET);
    if ($berr != 1) {die("BAD SEEK: $!");}
    my($bread) = read(B, $bbuf, $bsize);
    if ($bread != $bsize) {die("READ ERROR: $!");}

    my(@bvals) = map($_=ord($_), split(//, $bbuf));

    my($bval) = $bvals[0] + 256*$bvals[1];

    my($row) = floor($i/43200);
    my($col) = $i%43200;

    my($lat) = 90-(($row+.5)/21600*180);
    my($lng) = ($col+0.5)/43200*360-180;

    my($x, $y, $z) = sph2xyz($lng, $lat, 1, "degrees=1");

    $country{$bval}{x} += $aval*$x;
    $country{$bval}{y} += $aval*$y;
    $country{$bval}{z} += $aval*$z;
    $country{$bval}{pop} += $aval;
    $country{$bval}{points}++;
    $country{$bval}{parea} += cos($lat*$DEGRAD);
# }

}

for $i (sort keys %country) {
    my(@list) = ();
    for $j (keys %{$country{$i}}) {
	push(@list, "$j: $country{$i}{$j}");
    }
    print join(", ", "{cc: $i", @list),"}\n";
}

# TODO: put this function into bclib.pl

# https://stackoverflow.com/questions/770342/how-can-i-convert-four-characters-into-a-32-bit-ieee-754-float-in-perl

sub str2float {

    my($val) = @_;

    my(@bytes) = map($_=ord($_), split(//, $val));
    @bytes = reverse(@bytes);

    my($word) =
	($bytes[0] << 24) + ($bytes[1] << 16) + ($bytes[2] << 8) + $bytes[3];

    my($sign) = ($word & 0x80000000) ? -1 : 1;
    my ($expo) = (($word & 0x7F800000) >> 23) - 127;
    my ($mant) = ($word & 0x007FFFFF | 0x00800000);
    my ($num) = $sign * (2 ** $expo) * ( $mant / (1 << 23));

    return $num;
}

