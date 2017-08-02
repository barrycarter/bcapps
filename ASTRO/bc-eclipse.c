// determine azimuth/altitude of sun/moon for given earth location
// over period of time

// Usage: lat lon stime etime (latter 2 in unix seconds)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  SpiceDouble pos[3], normal[3], erad[3], north[3], proj[3];
  SpicePlane plane;
  SpiceInt dim = 0;

  // if insufficient argc, complain, don't just seg fault
  if (argc != 5) {
    printf("Usage: lat lon stime etime\n");
    exit(-1);
  }

  // process input
  double lat = atof(argv[1]);
  double lon = atof(argv[2]);
  double stime = atof(argv[3]);
  double etime = atof(argv[4]);

  // define north pole (TODO: has to be a better way to do this)
  north[0] = 0;
  north[1] = 0;
  north[2] = 1;

  // radii of Earth (0 and 1 are equatorial, 2 is polar)
  bodvrd_c("EARTH", "RADII", 3, &dim, erad);

  printf("ERAD (%d): %f %f %f\n", dim, erad[0], erad[1], erad[2]);

  // fixed ITRF93 position of lat/lon
  georec_c(lon*rpd_c(),lat*rpd_c(),0,erad[0],(erad[0]-erad[2])/erad[0], pos);

  // and the surface normal to this location
  surfnm_c(erad[0],erad[1],erad[2],pos,normal);

  // and the plane associated with this surface normal
  nvc2pl_c(normal, 1, &plane);

  // project the "north pole" vector to the plane
  vprjp_c(north, &plane, &proj);

  printf("PROJ (%f %f): %f %f %f\n", lat, lon, proj[0], proj[1], proj[2]);
  printf("POS (%f %f): %f %f %f\n", lat, lon, pos[0], pos[1], pos[2]);
  printf("SRFNM (%f %f): %f %f %f\n", lat, lon, normal[0], normal[1], normal[2]);

}
