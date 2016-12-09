/* Shows ECLIPDATE is broken */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main() {

  SpiceDouble et, lt, pos[6];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/eqeqdate.tf");
  furnsh_c("/home/barrycarter/SPICE/KERNELS/de431_part-1.bsp");
  furnsh_c("/home/barrycarter/SPICE/KERNELS/naif0011.tls");
  str2et_c("BC 9998-06-06 00:00:00", &et);

  //  spkgeo_c(10, et, "ECLIPDATE", 399, pos, &lt);
  //  spkezp_c(10, et, "ECLIPDATE", "NONE", 399, pos, &lt);
  //  spkezp_c(10, et, "EQEQDATE", "NONE", 399, pos, &lt);
  spkgeo_c(10, et, "EQEQDATE", "NONE", 399, pos, &lt);

  printf("ET: %f, POS: %f %f %f\n", et, pos[0], pos[1], pos[2]);

  return 0;
}
