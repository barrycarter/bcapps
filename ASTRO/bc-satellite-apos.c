// Determine the max distance from a planet to its satellites in terms
// of planet radius to see in what angular range one of the planet's
// satellites could occult a star (or whatever)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // state of Io at time = 0

  SpiceDouble state[6], lt;

  spkezr_c("501", 0, "IAU_JUPITER", "CN+S", "599", state, &lt);

  printf("STATE: %f %f %f %f %f %f\n", state[0], state[1], state[2], state[3], state[4], state[5]);

}
