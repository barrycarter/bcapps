#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

/*
                    rp      Perifocal distance.
                    ecc     Eccentricity.
                    inc     Inclination.
                    lnode   Longitude of the ascending node.
                    argp    Argument of periapsis.
                    m0      Mean anomaly at epoch.
                    t0      Epoch.
                    mu      Gravitational parameter.
*/

/* 

Thin wrapper around oscelt_c that computes osculating elements given:

  - center: the object being orbited
  - body: the object that is orbiting
  - et: the ephemeris time
  - frame: the frame for which to compute the parameters

*/


void osculatingElements(SpiceInt center, SpiceInt body, SpiceDouble et, char *frame, SpiceDouble elts[8]) {

  SpiceDouble starg[6], lt;

  // get position and velocity
  spkez_c(body, et, frame, "CN+S", center, starg, &lt);

  // get GM of center body
  SpiceInt dim;
  SpiceDouble mu[1];
  bodvcd_c(center, "GM", 1, &dim, mu);

  oscelt_c (starg, et, mu[0], elts);
}


// determine the osculating elements for a given object wrt to another
// object ever a given time in a given reference frame

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  char *strs[8] = {"rp", "ecc", "inc", "lnode", "argp", "m0", "t0", "mu"};

  SpiceDouble answer[8];

  for (double j=year2et(2010); j < year2et(2030); j+=86400) {

    osculatingElements(10, 299, j, "ECLIPJ2000", answer);

    double mult = 1;

    for (int i=0; i < 8; i++) {

      if (i >=2 && i <= 5) {mult = 180/pi_c();}

      printf("%s: %f \n", strs[i], answer[i]*mult);
    }
  }
}

