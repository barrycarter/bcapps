#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

# cheap hack
$str = << "MARK";
new
size 500,500
setpixel 0,0,0,0,0
string 255,255,255,100,100,small,hello
MARK
;

open(A,"|fly -q -o /tmp/test.gif");
print A $str;
close(A);

print "Content-type: image/gif\n\n";

system("cat /tmp/test.gif");

