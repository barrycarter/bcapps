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

void azalt(ConstSpiceChar *targ, SpiceDouble et, SpiceDouble lat, SpiceDouble lon) {

  SpiceDouble targetPosition[3], targetPositionTopographic[3];
  SpiceDouble observerPosition[3], surfaceNormal[3];
  SpiceDouble lt;

    //targpos[3], normal[3], north[3], state[3], surf[3], lt;
    //  SpicePlane plane;

  // HACK: cheating a bit here hardcoding Earth's radii

  // find position of object in ITRF93 frame
  // TODO: this CANNOT ALWAYS BE SUN!
  spkezp_c(10, et, "ITRF93", "CN+S", 399, targetPosition, &lt);

  // find observer position in ITRF93
  georec_c(lon, lat, 0, 6378.137, 0.0033528128, observerPosition);

  // subtract to get topographic position
  vsub_c(targetPosition, observerPosition, targetPositionTopographic);

  // the surface normal vector from the observer (z axis)
  surfnm_c(6378.137, 6378.137, 6356.7523, observerPosition, surfaceNormal);

  printf("observerPosition: %f %f %f\n", observerPosition[0], observerPosition[1], observerPosition[2]);
  printf("surfaceNormal: %f %f %f\n", surfaceNormal[0], surfaceNormal[1], surfaceNormal[2]);

  // angle between surfaceNormal and object
  double normalAngle = vsep_c(surfaceNormal, targetPositionTopographic);

  double unixtime = et2unix(et);
  printf("%f %f\n", unixtime, normalAngle/rpd_c());

  return;

  /*

  // pos = fixed ITRF93 position of lat/lon
  georec_c(lon, lat, 0, 6378.137, 0.0033528128, pos);

  // surface normal there
  surfnm_c(6378.137, 6378.137, 6356.7523, pos, normal);

  // the plane perpendicular to normal but passing through origin
  nvc2pl_c(normal, 0, &plane);

  // projection of z vector to this plane (ie, direction "north")
  SpiceDouble z[3] = {0,0,1};
  vprjp_c(z, &plane, north);

  // the matrix rotating ITRF93 to topographic frame (z = up, y = north)
  SpiceDouble matrix[3][3];

  //  twovec_c(north, 2, normal, 3, matrix);
  twovec_c(normal, 3, north, 2, matrix);

  // vector to target at time

  printf("STATE: %f %f %f\n", state[0], state[1], state[2]);

  // rotate into topographic frame
  SpiceDouble loc[3];
  mtxv_c(matrix, state, loc);
  printf("ROTATED: %f %f %f\n", loc[0], loc[1], loc[2]);

  // spherical coordinates
  SpiceDouble r, colat, lont;
  recsph_c(loc, &r, &colat, &lont);

  printf("%f %f %f\n", r, colat/rpd_c(), lont/rpd_c());

  // project this vector to plane
  vprjp_c(state, &plane, surf);

  // the angle between the surface and north vectors
  //  SpiceDouble az = acos(vdot_c(surf, north)/vnorm_c(surf)/vnorm_c(north));

  // the angle between the normal and object

  // printf("ANGLE: %f\n", az/rpd_c());

  */

  /*
  printf("STATE (%f %f %f): %f %f %f\n", lat, lon, stime, state[0], state[1], state[2]);
  printf("PROJ (%f %f): %f %f %f\n", lat, lon, north[0], north[1], north[2]);
  printf("POS (%f %f): %f %f %f\n", lat, lon, pos[0], pos[1], pos[2]);
  printf("SRFNM (%f %f): %f %f %f\n", lat, lon, normal[0], normal[1], normal[2]);
  */

}

int main(int argc, char **argv) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // currently does nothing
  //  azalt("Sun", unix2et(0), 35*rpd_c(), -106*rpd_c());


  for (int i=1554962400; i<1555048800; i+=600) {
    //    printf("I: %d ",i);
    azalt("Sun", unix2et(i), 35*rpd_c(), -106*rpd_c());
  }

  return 0;

}
