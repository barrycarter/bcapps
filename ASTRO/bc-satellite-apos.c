// Determine the max distance from a planet to its satellites in terms
// of planet radius to see in what angular range one of the planet's
// satellites could occult a star (or whatever)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

char *strs[8] = {"rp", "ecc", "inc", "lnode", "argp", "m0", "t0", "mu"};

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  char *planet = "399";
  char *moon = "301";

  // NOTE: this frame MUST be inertial (not body fixed)
  char *frame = "ECLIPJ2000";

  // planet mass parameter

  SpiceInt dim;
  SpiceDouble mu[1];
  bodvrd_c(planet, "GM", 1, &dim, mu);

  printf("PLANET(%d) MP: %f\n", dim, mu[0]);

  // state of moon at time = 0

  SpiceDouble state[6], lt, elts[8];
  spkezr_c(moon, 0, frame, "CN+S", planet, state, &lt);

  // osculating elements wrt planet

  oscelt_c(state, 0, mu[0], elts);

  printf("MOONSTATE: %f %f %f %f %f %f\n", state[0], state[1], state[2], state[3], state[4], state[5]);

  for (int i=0; i < 8; i++) {
    printf("%s: %f\n", strs[i], elts[i]);
  }

}
