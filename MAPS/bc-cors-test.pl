#!/bin/perl

# This script runs on test.barrycarter.info and does nothing
# except test CORS headers so that people can view test.html and
# similar files from anywhere, not just on my server

require "/usr/local/lib/bclib.pl";

# print "Access-Control-Allow-Origin: *\nContent-type: text/plain\n\nthis is some text\n";

print "Access-Control-Allow-Origin: *\nContent-type: application/octet-stream\n\n";

# for consistency

srand(20190528);

# some random bytes for testing


for (1..10000) {
  print chr(floor(rand()*256));
}


