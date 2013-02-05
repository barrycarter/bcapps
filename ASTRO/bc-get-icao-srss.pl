#!/bin/perl

# Obtains "exact" times of sun/moon rise/set (and civil twilight) in
# 2013 for all ICAO locations and enters them into db for no
# compelling reason

require "/usr/local/lib/bclib.pl";
$posturl = "http://aa.usno.navy.mil/cgi-bin/aa_rstablew.pl";

# test!
$poststr = "FFX=2&xxy=2013&type=0&place=LABEL&xx0=-1&xx1=106&xx2=30&yy0=1&yy1=35&yy2=05&zz1=0&zz0=-1&ZZZ=END";

($out,$err,$res) = cache_command("curl -d '$poststr' '$posturl'","age=3600");

debug("OUT: $out");

