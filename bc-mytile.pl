#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

push(@INC,"/usr/local/lib");
require "bclib.pl";

# ($r, $g, $b) = (int(rand(256)), int(rand(256)), int(rand(256)));

%query = str2hash($ENV{QUERY_STRING});


($x, $y) = ($query{x}/2**$query{zoom}*1000, $query{y}/2**$query{zoom}*1000);


($r, $g, $b) = (int($query{x}/(2**$query{zoom})*255),
		int($query{y}/(2**$query{zoom})*255),
		0);

$printstr = "$query{x},$query{y},$query{zoom}";
# cheap hack
$str = << "MARK";
new
size 256,256
setpixel 0,0,255,255,255
string 0,0,0,128,128,large,$printstr
# stringup 255,255,255,128,128,large,$printstr
# dline 0,0,256,256,255,0,0
# dline 256,0,0,256,255,0,0
rect 0,0,256,256,255,0,0
# string 255,255,255,0,150,small,$r/$g/$b
MARK
;

$f = my_tmpfile("tile");
open(A,"|fly -q -o $f");
print A $str;
close(A);

print "Content-type: image/gif\n\n";

system("cat $f");

