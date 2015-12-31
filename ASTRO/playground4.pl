#!/bin/perl

require "/usr/local/lib/bclib.pl";
use Inline C => Config => LIBS => "-I /home/barrycarter/SPICE/cspice/include -L/home/barrycarter/SPICE/cspice/lib/EXTRACTED/ -lcspice -lm";

debug(furnsh_c(""));





die "TESTING";





# FFI testing

use FFI::Raw;

my($bar) = FFI::Raw->new
("/home/barrycarter/SPICE/cspice/lib/EXTRACTED/cspice.so",
 "furnsh_c", FFI::Raw::void, FFI::Raw::str);

my($foo) = FFI::Raw->new
("/home/barrycarter/SPICE/cspice/lib/EXTRACTED/cspice.so",
 "bodvar_c", FFI::Raw::void, FFI::Raw::str, FFI::Raw::str, FFI::Raw::int, FFI::Raw::ptr, FFI::Raw::ptr);

$bar->call("/home/barrycarter/BCGIT/ASTRO/standard.tm");

$foo->call("earth", "RADII", 3, $dim, $values);



