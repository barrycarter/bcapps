#!/bin/perl

# attempts to create a logarithmic "zooming timeline" using google maps

require "/usr/local/lib/bclib.pl";

# get google query
%query = str2hash($ENV{QUERY_STRING});

# determine x/y coords (in absolute 2^29 coords)
($x, $y) = ($query{x}/2**(29-$query{zoom}), $query{y}/2**(29-$query{zoom}));

# and the next east x coord
$nx = $query{x}+1/2**(29-$query{zoom});

# yoctoseconds from year 2000 = log base 1+10**-6 of x (I probably need
# to adjust this to be less insane), sign preserved
$lsec = log($x)/log(1+10**-6)/10**24;
$rsec = log($nx)/log(1+10**-6)/10**24;

# determine other useful information

$printstr = << "MARK";
x=$query{x},y=$query{y},zoom=$query{zoom}
LSEC: $lsec
RSEC: $rsec
MARK
;

# hideous...
print "Content-type: image/gif\n\n";
open(A,"|fly -q");

print A << "MARK";
new
size 256,256
setpixel 0,0,0,0,255
rect 0,0,256,256,255,0,0
dline 0,128,256,128,255,128,0
dline 128,0,128,256,255,128,0
MARK
;

$y=0;

for $i (split(/\n/, $printstr)) {
  print A "string 255,255,255,2,$y,large,$i\n";
  $y+=20;
}

close(A);
