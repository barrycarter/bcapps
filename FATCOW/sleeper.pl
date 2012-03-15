#!/usr/bin/perl

# can I run daemons on fatcow?

print "Content-type: text/plain\n\n";

print "STARTING";

if (fork()) {exit;}

sleep(5);
print "GOING";
$now = time();

system("date > $now &");
