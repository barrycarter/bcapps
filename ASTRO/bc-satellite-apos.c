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

Mars: 23480km (2 moons)
Jupiter: 40492246km (72 moons)
Saturn: 36068000km (53 moons)
Uranus: 29552162km (27 moons)
Neptune: 93661806km (14 moons)
Pluto: 340945km (5 moons)

*/

char *strs[8] = {"rp", "ecc", "inc", "lnode", "argp", "m0", "t0", "mu"};

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // NOTE: the reference frame MUST be inertial (not body fixed)

  SpiceInt planet = 399;

  // planet mass parameter

  SpiceInt dim;
  SpiceDouble mu[1];
  bodvcd_c(planet, "GM", 1, &dim, mu);

  printf("PLANET(%d) MP: %f\n", dim, mu[0]);


  for (int i=301; i <= 301; i++) {

    // TODO: figure this out
    if (i == 558) {
      printf("558 sucks\n");
      continue;
    }

    for (SpiceDouble et = year2et(1980); et < year2et(2038); et += 86400) {

      // state of moon at time et

      SpiceDouble state[6], lt, elts[8];
      spkez_c(i, et, "ECLIPJ2000", "CN+S", planet, state, &lt);

      // osculating elements wrt planet
      oscelt_c(state, et, mu[0], elts);

      //    printf("MOONSTATE: %d %f %f %f %f %f %f\n", i, state[0], state[1], state[2], state[3], state[4], state[5]);

      SpiceDouble apDist = elts[0]/(1-elts[1])*(1+elts[1]);
      
      printf("APDIST: %d %f %f %f\n", i, et2unix(et), apDist, elts[1]);
    }
  }
}
