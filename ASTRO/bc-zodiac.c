/*

 Attempts to answer http://astronomy.stackexchange.com/questions/19301/period-of-unique-horoscopes/19306#19306

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"


// the next two includes are part of the CSPICE library
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000

// returns the ecliptic longitude of planet at et, as viewed from Earth

// TODO: I could make this more "NASA-like" by having it change a
// pass-by-reference variable and return both latitude and longitude
// and even distance (full spherical coords)

SpiceDouble ecliptic_longitude (SpiceInt planet, SpiceDouble et) {

  // array to hold the XYZ and lt results from spkezp_c
  SpiceDouble res[3];
  SpiceDouble lt;

  spkezp_c(planet, et, "ECLIPDATE", "LT+S", 399, res, &lt);

  printf("%f -> %f %f %f\n", et, res[0], res[1], res[2]);

  return atan2(res[1],res[0]);

}

int main (int argc, char **argv) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");

  // should be 30 eclip long
  printf("%f\n", ecliptic_longitude(1, unix2et(1490980772))*dpr_c());

}
