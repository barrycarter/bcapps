#!/bin/perl

use Inline Python;

$s = new Sun();
print "SUN: $s\n";
$m = new Moon();

__END__
__Python__
from ephem import Sun as Sun;
from ephem import Moon as Moon;

