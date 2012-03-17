#!/usr/bin/perl

# can I run daemons on fatcow?

print "Content-type: text/plain\n\n";

print "STARTING";
system("(sleep 10; date > $now) &");
print "GOING";

