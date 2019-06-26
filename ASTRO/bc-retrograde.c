/* Compute retrogrades for given planet */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main (int argc, char **argv) {

  // the standard ephemerides
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // 1970 to 2038 (all "Unix time") for testing
  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

}

/* the change in `planet`'s ecliptic longitude as viewed from Earth */

void eclipticLongitudeDelta(SpiceDouble et, SpiceDouble *value) {
  
