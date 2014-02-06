#!/bin/perl

use Inline Python;

$eph = new de421();
# $eph = new Ephemeris("de421");

__END__
__Python__
from jplephem import Ephemeris as Ephemeris;
import de421 as de421;

