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

  // TODO: get these from args
  ConstSpiceChar *planet = "399";

  // TODO: why did this break
  //  SpiceDouble time = unix2et(1585246372);

  SpiceDouble time = 0; // TODO: fix me!
  SpiceInt npts = 100;

  furnsh_c("bc-maxkernel.tm");

  // TODO: maybe penumbral for where sunset is occurring

  // TODO: make et real, fix frame

  SpiceDouble trgepc, obspos[3], trmpts[100][3];

  edterm_c("UMBRAL", "10", planet, time, "IAU_EARTH", "CN+S", planet, npts,
  	   &trgepc, obspos, trmpts);

  for (int i=0; i<npts; i++) {
    printf("POINT(%d): %f %f %f\n", i, trmpts[i][0], trmpts[i][1], trmpts[i][2]);
  }


  exit(0);
  /*

  // determine the radii of the given object

  SpiceInt dim;
  SpiceDouble rad[3];
  bodvcd_c(planet, "RADII", 3, &dim, rad);

  printf("RADII: %f %f %f\n", rad[0], rad[1], rad[2]);

  georec_c(longitude, latitude, elevation/1000., radii[0], 
           (radii[0]-radii[2])/radii[0], pos);
  */

}
