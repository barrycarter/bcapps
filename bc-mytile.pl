#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

require "/usr/local/lib/bclib.pl";

%query = str2hash($ENV{QUERY_STRING});


($x, $y) = ($query{x}/2**$query{zoom}*1000, $query{y}/2**$query{zoom}*1000);

# $printstr = "$query{x},$query{y},$query{zoom}";

$printstr = << "MARK";
x=$query{x}
y=$query{y}
z=$query{zoom}
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
MARK
;

$y=0;

for $i (split(/\n/, $printstr)) {
  print A "string 255,255,255,0,$y,large,$i\n";
  $y+=20;
}

close(A);
