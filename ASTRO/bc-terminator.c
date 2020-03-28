#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"


// Usage: $0 --id=naif_id --time=time_in_unix_seconds --refract=0|1
// (refraction is computed for earth only)

// TODO: error to set refraction for non-Earth

// TODO: refraction?

// TODO: getopts for options in C

int main(int argc, char **argv) {

  //  int opt;

  while (getopt_long (argc, argv, "abc:d:f:", long_options, &option_index) != -1) {
    printf("%p\n", long_options);
  }

  furnsh_c("bc-maxkernel.tm");

  // TODO: get these from args
  ConstSpiceChar *planet = "499", *frame = "IAU_MARS";
  SpiceDouble time = unix2et(1585353280);
  SpiceInt npts = 100;

  // TODO: maybe penumbral for where sunset is occurring
  // TODO: need to fix frame from IAU_EARTH

  SpiceDouble trgepc, obspos[3], trmpts[100][3], r, lng, lat;

  // TODO: best frame for Earth is ITRF93 NOT IAU_EARTH

  edterm_c("UMBRAL", "10", planet, time, frame, "CN+S", planet, npts,
  	   &trgepc, obspos, trmpts);

  for (int i=0; i<npts; i++) {

    reclat_c(trmpts[i], &r, &lng, &lat);

    printf("POINT(%d): %f %f %f\n", i, r, lng*dpr_c(), lat*dpr_c());
  }
  return 0;
}
