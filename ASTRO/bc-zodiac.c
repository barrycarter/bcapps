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
  return atan2(res[1],res[0]);
}

// trivial psuedo-derivative sign

int d_ecliptic_longitude (SpiceInt planet, SpiceDouble et) {
  
  SpiceDouble delta = ecliptic_longitude(planet,et+1) - ecliptic_longitude(planet,et-1);

  // TODO: assumes result is non-zero, 0 is a seriously special case
  return delta>0?1:-1;
}

// returns the distance to the nearest cusp (multiple of 30 degrees)
// for a given planet/time

SpiceDouble distance_to_cusp (SpiceInt planet, SpiceDouble et) {
  // TODO: there MUST be a better way to write this!
  return 15*rpd_c()-fabs(fabs(fmod(ecliptic_longitude(planet, et), 30*rpd_c()))-15*rpd_c());
}

int main (int argc, char **argv) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  // TODO: this is just plain silly
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");

  for (int i=1; i<=366; i++) {
    printf("%d %f %f %d\n", i, 
	   ecliptic_longitude(1, unix2et(86400*(i-1)+1483228800))*dpr_c(),
	   distance_to_cusp(1, unix2et(86400*(i-1)+1483228800))*dpr_c(),
	   d_ecliptic_longitude(1, unix2et(86400*(i-1)+1483228800))
	   );
  }
}
