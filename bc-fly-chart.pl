#!/bin/perl

# quick script to show which characters fly can display

$incr=20;
$ysize=$incr*27;
print "new\nsize 400,$ysize\nfill 0,0,0,0,0\n";
print "string 255,255,255,0,0,giant,    0  1  2  3  4  5  6  7  8  9\n";

for $i (0..25) {
    $pos+=$incr;
    $string=sprintf("%0.2d ",$i);
    for $j (0..9) {
	$string=$string." ".chr($i*10+$j)." ";
    }
    print "string 255,255,255,0,$pos,giant,$string\n";
}

