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

  // Jupiter mass parameter

  SpiceInt dim;
  SpiceDouble mu;
  bodvrd_c("599", "GM", 1, &dim, &mu);


  // state of Io at time = 0

  SpiceDouble state[6], lt, elts[8];
  spkezr_c("501", 0, "IAU_JUPITER", "CN+S", "599", state, &lt);

  // osculating elements wrt Jupiter

  oscelt_c(state, 0, mu, elts);

  //  printf("STATE: %f %f %f %f %f %f\n", state[0], state[1], state[2], state[3], state[4], state[5]);

  for (int i=0; i < 8; i++) {
    printf("%s: %f\n", strs[i], elts[i]);
  }

}
