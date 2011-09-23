#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

push(@INC,"/usr/local/lib");
require "bclib.pl";

# cheap hack
$str = << "MARK";
new
size 200,200
setpixel 0,0,0,0,0
string 255,255,255,0,100,small,$ENV{QUERY_STRING}
MARK
;

$f = my_tmpfile("tile");
open(A,"|fly -q -o $f");
print A $str;
close(A);

print "Content-type: image/gif\n\n";

system("cat $f");

