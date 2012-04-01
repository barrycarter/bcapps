#!/bin/perl

# failing attempt to create trivial "API" to openstudy.com (good
# concept, hideous implementation)

require "bclib.pl";
require "/home/barrycarter/bc-private.pl";

system("curl -H 'Cookie: $openstudy{cookie}' -o /tmp/test1.txt http://openstudy.com/study?login#/groups/Mathematics");

