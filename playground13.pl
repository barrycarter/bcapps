#!/bin/perl

# TOR testing

require "/usr/local/lib/bclib.pl";

$ENV{LD_PRELOAD} = "/lib/libtsocks.so";

my($out,$err,$res) = cache_command2("curl http://checkip.dyndns.org/");

debug("OUT: $out");
