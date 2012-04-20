#!/bin/perl

# Trivial wrapper around nagios tests to publish to web so I can have
# montastic check them <h>(yes, I put a lot of effort into avoiding
# effort)</h>

print "Content-type: text/plain\n\n";

# TODO: allow more options and other programs (if needed)

system("check_ntp -H 0.us.pool.ntp.org");
