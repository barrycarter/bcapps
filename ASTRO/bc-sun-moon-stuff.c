/* determines moon/sun rise/set/twilight times */

// the angular separation from zenith of a given body at a given time
// in a given place; because I plan to feed this routine to gfq, most
// "parameters" are global

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// return the azimuth and altitude of an object at a given time from a
// given location on Earth

SpiceDouble *azalt(ConstSpiceChar *targ, SpiceDouble et, ConstSpiceChar *ref, SpiceDouble lat, SpiceDouble lon) {

  SpiceDouble pos[3], normal[3], north[3], state[3], surf[3], res[2], lt;
  SpicePlane plane;

  // HACK: cheating a bit here hardcoding Earth's radii

  // pos = fixed ITRF93 position of lat/lon
  georec_c(lon*rpd_c(),lat*rpd_c(), 0, 6378.137, 0.0033528128, pos);

  // surface normal there
  surfnm_c(6378.137, 6378.137, 6356.7523, pos, normal);

  // the plane perpendicular to normal but passing through origin
  nvc2pl_c(normal, 0, &plane);

  // projection of z vector to this plane (ie, direction "north")
  SpiceDouble z[3] = {0,0,1};

  vprjp_c(z, &plane, north);

  // vector to target at time
  spkcpo_c(targ, et, "ITRF93", "OBSERVER", "CN+S", pos, "Earth", "ITRF93", state, &lt);

  // project this vector to plane
  vprjp_c(state, &plane, surf);

  // the angle between the surface and north vectors
  double dang = acos(vdot_c(surf, north)/vnorm_c(surf)/vnorm_c(north));

  printf("ANGLE: %f\n", dang/rpd_c());

  return res;

  /*
  printf("STATE (%f %f %f): %f %f %f\n", lat, lon, stime, state[0], state[1], state[2]);
  printf("PROJ (%f %f): %f %f %f\n", lat, lon, north[0], north[1], north[2]);
  printf("POS (%f %f): %f %f %f\n", lat, lon, pos[0], pos[1], pos[2]);
  printf("SRFNM (%f %f): %f %f %f\n", lat, lon, normal[0], normal[1], normal[2]);
  */

}

int main(int argc, char **argv) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");



  return 0;

}
