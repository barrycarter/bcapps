#!/bin/perl

# attempts to create a logarithmic "zooming timeline" using google maps

require "/usr/local/lib/bclib.pl";

# get google query
%query = str2hash($ENV{QUERY_STRING});

# determine LOG of x coords (in absolute 2^29 coords) [ignoring y]
# this formula after a lot of work, which I probably should've shown
$logx = 44.9004 - 1.54829*$query{z} + 2.23371*log($query{x});
$lognx = 44.9004 - 1.54829*$query{z} + 2.23371*log($query{x}+1);

# determine other useful information

$printstr = << "MARK";
x=$query{x},y=$query{y},zoom=$query{zoom}
LX: $logx
LNX: $lognx
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
