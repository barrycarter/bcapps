#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

// TODO: refraction?

// TODO: getopts for options in C

int main(int argc, char **argv) {

  furnsh_c("bc-maxkernel.tm");

  // TODO: get these from args
  ConstSpiceChar *planet = "399";
  SpiceDouble time = unix2et(1585250121);
  SpiceInt npts = 100;

  // TODO: maybe penumbral for where sunset is occurring
  // TODO: need to fix frame from IAU_EARTH

  SpiceDouble trgepc, obspos[3], trmpts[100][3], r, lng, lat;

  edterm_c("UMBRAL", "10", planet, time, "IAU_EARTH", "CN+S", planet, npts,
  	   &trgepc, obspos, trmpts);

  for (int i=0; i<npts; i++) {

    reclat_c(trmpts[i], &r, &lng, &lat);

    printf("POINT(%d): %f %f %f\n", i, r, lng*dpr_c(), lat*dpr_c());
  }
  return 0;
}
