#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# TODO: cleanup this file -- lots of stuff has been (or should be)
# moved to production

# chunks are normally separated with 'die "TESTING";' (TODO: use
# subroutines instead?)

# TODO: create a version of cache_command that knows how often a given
# URL is updated, and only dls as needed; eg, if URL is updated every
# 6h at 0000,0600,1200,1800 GMT, use that info to dl as needed instead
# of "is my cache x hours old"

require "/usr/local/lib/bclib.pl";
# below lets me override functions when testing
require "/home/barrycarter/BCGIT/bclib-playground.pl";
# require "bc-astro-lib.pl";
require "bc-weather-lib.pl";
# starting to store all my private pws, etc, in a single file
require "/home/barrycarter/bc-private.pl";
use XML::Simple;
use Data::Dumper 'Dumper';
use Time::JulianDay;
use XML::Bare;
$Data::Dumper::Indent = 0;
require "bc-twitter.pl";
use GD;
use Algorithm::GoldenSection;
use Inline Python;

$o = new Observer();
$s = new Sun();
debug("S: $s and $o");
$o->{date} = "2013/11/27";
$o->{lat} = "35.1";
$o->{lon} = "-106.5";
$o->{elevation} = 1528;
$o->{pressure} = 0;
debug($o,$s);
debug($o->next_rising($s));
$m = new Moon();
debug("M: $m");
# debug($o->next_rising($m));

__END__
__Python__
from ephem import Observer as Observer;
from ephem import Sun as Sun;
from ephem import Moon as Moon;
