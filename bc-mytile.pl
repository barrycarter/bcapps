#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

print "Content-type: image/jpeg\n\n";

system("cat /sites/TEST/moon.png");
