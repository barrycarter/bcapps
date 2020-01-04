#!/bin/perl

# TODO: move subroutine to bclib.pl

require "/usr/local/lib/bclib.pl";

@dfw = (-96.8066583160554, 32.7830548753175);
@abq = (-106.651138463684, 35.0844869067959);
@nrt = (140.316661615173, 35.7833311428625);
@nrt = (0, 0);
# 139.691706877453, 35.6894967370925);

# TODO: something seriously broken

my(@l) = (@dfw, @nrt, @abq);

map($_*=$DEGRAD, @l);

debug("L", @l);

gc2Pt(@l);

# gc2Pt(0*$DEGRAD, 10*$DEGRAD, 10*$DEGRAD, 20*$DEGRAD, 5*$DEGRAD, 15*$DEGRAD);

=item gc2Pt($lngB, $latB, $lngD, $latD, $lngC, $latC)

Given three points B, C, and D, return the point on the great circle
between B and D that is closest to C and the distance to C from that
point

TODO: find closed forms

=cut

sub gc2Pt {

    my($lngB, $latB, $lngD, $latD, $lngC, $latC) = @_;

    my($a, $b, $c, $d, $e, $f, $x, $y, $z) = (
	cos($latB)*cos($lngB),
	-cos($latB)*cos($lngB)+cos($latD)*cos($lngD),
	-cos($latB)*sin($lngB)+cos($latD)*sin($lngD),
	cos($latB)*sin($lngB),
	sin($latB),
	sin($latD)-sin($latB),
	cos($latC)*cos($lngC),
	cos($latC)*sin($lngC), 
	sin($latC)
	);

    my($t) = (-$a*$b+$b*$x - $c*$d+ $c*$y - $e*$f+ $f*$z)/($b**2 + $c**2 + $f**2);

    my(@ptB) = sph2xyz($lngB, $latB, 1);
    my(@ptD) = sph2xyz($lngD, $latD, 1);

    my(@ptT);

    for ($i=0; $i<3; $i++) {$ptT[$i] = $ptB[$i] + $t*($ptD[$i]-$ptB[$i])}

    my(@ptTsph) = xyz2sph(@ptT);

    debug("T: $t");
    debug("PTT:", $ptTsph[0]/$DEGRAD, $ptTsph[1]/$DEGRAD, $ptTsph[2]);

    debug("DIST:", gcdist($ptTsph[1], $ptTsph[0], $latC, $lngC));


    # TODO: case where t<0 or t>1

}

