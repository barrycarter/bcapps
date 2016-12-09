/* Shows ECLIPDATE is broken */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main() {

  SpiceDouble et, lt, pos[3];

  furnsh_c("/home/barrycarter/SPICE/KERNELS/de431_part-1.bsp");
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");
  furnsh_c("/home/barrycarter/SPICE/KERNELS/naif0011.tls");

  str2et_c("BC 9998-08-20 00:00:00", &et);
  printf("ET: %f\n",et);
  spkgeo_c(10, et, "ECLIPDATE", 399, pos, &lt);
  printf("ET: %f, LT: %f\n",et);

  printf("ET: %f POS: %f, %f, %f\n", et, pos[0], pos[1], pos[2]);

  return 0;
}
