#!/bin/perl

# This script runs on test.barrycarter.info and does nothing
# except test CORS headers so that people can view test.html and
# similar files from anywhere, not just on my server

print "Access-Control-Allow-Origin: *\nContent-type: text/plain\n\nthis is some text\n";
