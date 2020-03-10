// Determine the max distance from a planet to its satellites in terms
// of planet radius to see in what angular range one of the planet's
// satellites could occult a star (or whatever)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

/*

Max distances:






*/

char *strs[8] = {"rp", "ecc", "inc", "lnode", "argp", "m0", "t0", "mu"};

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // NOTE: the reference frame MUST be inertial (not body fixed)

  SpiceInt planet = 599;

  // planet mass parameter

  SpiceInt dim;
  SpiceDouble mu[1];
  bodvcd_c(planet, "GM", 1, &dim, mu);

  printf("PLANET(%d) MP: %f\n", dim, mu[0]);


  for (int i=501; i < 573; i++) {

    // TODO: figure this out
    if (i == 558) {
      printf("558 sucks\n");
      continue;
    }

    // TODO: maybe loop
    SpiceDouble et = unix2et(0);

  // state of moon at time et

  SpiceDouble state[6], lt, elts[8];
  spkez_c(i, et, "ECLIPJ2000", "CN+S", planet, state, &lt);

  // osculating elements wrt planet

  oscelt_c(state, et, mu[0], elts);

  printf("MOONSTATE: %d %f %f %f %f %f %f\n", i, state[0], state[1], state[2], state[3], state[4], state[5]);

  for (int j=0; j < 8; j++) {
    printf("%s: %f\n", strs[j], elts[j]);
  }
  }
}
