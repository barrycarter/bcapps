#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

push(@INC,"/usr/local/lib");
require "bclib.pl";

# ($r, $g, $b) = (int(rand(256)), int(rand(256)), int(rand(256)));

%query = str2hash($ENV{QUERY_STRING});

($r, $g, $b) = (int($query{x}/(2**$query{zoom})*255),
		int($query{y}/(2**$query{zoom})*255),
		0);
# cheap hack
$str = << "MARK";
new
size 200,200
setpixel 0,0,$r,$g,$b
string 255,255,255,0,100,small,$ENV{QUERY_STRING}
string 255,255,255,0,150,small,$r/$g/$b
MARK
;

$f = my_tmpfile("tile");
open(A,"|fly -q -o $f");
print A $str;
close(A);

print "Content-type: image/gif\n\n";

system("cat $f");

