/* Shows ECLIPDATE is broken */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main() {

  SpiceDouble et;
  SpiceDouble lt;
  SpiceDouble pos[3];

  furnsh_c("/home/barrycarter/SPICE/KERNELS/de431_part-1.bsp");
  furnsh_c("/home/barrycarter/SPICE/KERNELS/naif0011.tls");

  str2et_c("BC 9998-08-20 00:00:00", &et);
  printf("ALPHA: %f\n",et);
  spkgeo_c(10, et, "J2000", 399, pos, &lt);
  printf("BETA: %f\n",et);

  return 0;
}
