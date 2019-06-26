/* Compute retrogrades for given planet */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

// TODO: make this a parameter, not a constant

SpiceInt planet = 4;

/* whether planet is in retrograde, true = in retrograde */

void retrogradeQ(SpiceDouble et, SpiceBoolean *value) {

  SpiceDouble v[3], lt, lng0, lng1;

  // planet ecliptic longitude at 5 seconds before and after given time

  spkezp_c(planet, et+5, "ECLIPDATE","CN+S", 399, v, &lt);
  lng0 = atan2(v[1], v[0]);

  spkezp_c(planet, et+10, "ECLIPDATE","CN+S", 399, v, &lt);
  lng1 = atan2(v[1], v[0]);

  printf("%f %f\n", lng0, lng1);

  // TODO: handle 2pi "wraparound" case

  // TODO: just testing
  *value = (lng1 < lng0);

}

int main (int argc, char **argv) {

  SpiceBoolean test;

  // the standard ephemerides

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  for (double i=year2et(2018); i < year2et(2020); i+=3600) {
    retrogradeQ(i, &test);
    printf("TEST %f %d\n", et2unix(i), test);
  }

  // 1970 to 2038 (all "Unix time") for testing
  //  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

}

  
