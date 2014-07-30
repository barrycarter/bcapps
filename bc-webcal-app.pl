#!/bin/perl

# Firefox won't save webcal:// URLs to disk by itself, so I'm
# assigning them to this app, which will

chdir("/home/barrycarter/Download/");
$ARGV[0]=~s/webcal/http/;
system ("curl -LO $ARGV[0] 1> /tmp/curl.out 2> /tmp/curl.err");
