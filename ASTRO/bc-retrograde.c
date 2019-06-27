/* Compute retrogrades for given planet */

/* See https://astronomy.stackexchange.com/questions/27468/table-of-dates-for-planet-retrograde-motion */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

// this has to be global

SpiceInt planet;

/* the psuedo-derivative of the ecliptic longitude for global `planet` */

void DEclipLong(SpiceDouble et, SpiceDouble *value) {

  SpiceDouble v[3], lt, lng0, lng1;

  // planet ecliptic longitude at 5 seconds before and after given time

  spkezp_c(planet, et+5, "ECLIPDATE","CN+S", 399, v, &lt);
  lng0 = atan2(v[1], v[0]);

  spkezp_c(planet, et+10, "ECLIPDATE","CN+S", 399, v, &lt);
  lng1 = atan2(v[1], v[0]);

  // CSPICE seems to ignore this case anyway, but when a planet's
  // ecliptic longitude 'decreases' from 359+ degress to ~0 degrees,
  // this is actually an increase

  if (lng1-lng0 < -pi_c()) {lng1 += twopi_c();}

  *value = lng1-lng0;

}

// given a prefix (string), window (collection of intervals) and a
// function, display (print) the value of the function at each
// endpoint of each interval with prefix (which I will use to tell me
// what I am computing)

void show_results (SpiceCell result) {

  SpiceInt i;
  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end;

  for (i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("%d %f %f\n", planet, beg, end);
  }
}

int main (int argc, char **argv) {

  // the planet
  planet = atoi(argv[1]);

  // to hold the results
  SPICEDOUBLE_CELL(result, 200000);
  SPICEDOUBLE_CELL(cnfine, 2);

  // the standard ephemerides
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // 1970 to 2038 (all "Unix time") for testing

  wninsd_c(year2et(1970), year2et(1980), &cnfine);

  gfuds_c(DEclipLong, isDecreasing, "<", 0, 0, 86400., 5000, &cnfine, &result);

  show_results(result);

}

  
