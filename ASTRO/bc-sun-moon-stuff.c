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
// given location on Earth (topographicSpherical is the return value)

void azalt(SpiceInt targ, SpiceDouble et, SpiceDouble lat, SpiceDouble lon, SpiceDouble *topographicSpherical) {

  SpiceDouble targetPosition[3], targetPositionTopographic[3];
  SpiceDouble observerPosition[3], surfaceNormal[3], eastVector[3];
  SpiceDouble itrf2TopographicMatrix[3][3], topographicPosition[3];
  SpiceDouble topoR, topoLat, topoLon;
  SpiceDouble lt;
  SpiceDouble northVector[3] = {0,0,1};

  // HACK: cheating a bit here hardcoding Earth's radii

  // find position of object in ITRF93 frame
  spkezp_c(targ, et, "ITRF93", "CN+S", 399, targetPosition, &lt);

  // find observer position in ITRF93
  georec_c(lon, lat, 0, 6378.137, 0.0033528128, observerPosition);

  // subtract to get topographic position
  vsub_c(targetPosition, observerPosition, targetPositionTopographic);

  // the surface normal vector from the observer (z axis)
  surfnm_c(6378.137, 6378.137, 6356.7523, observerPosition, surfaceNormal);

  // the north cross the normal vector yields an east pointing vector in plane
  vcrss_c(northVector, surfaceNormal, eastVector);

  // construct the matrix that converts ITRF to topographic, east = x
  twovec_c(surfaceNormal, 3, eastVector, 1, itrf2TopographicMatrix);

  // apply the matrix to the ITRF coords
  mxv_c(itrf2TopographicMatrix, targetPositionTopographic, topographicPosition);

  // convert to spherical coordinates
  recsph_c(topographicPosition, &topoR, &topoLat, &topoLon);

  // and "return"
  topographicSpherical[0] = halfpi_c()-topoLon;
  topographicSpherical[1] = halfpi_c()-topoLat;
  topographicSpherical[2] = topoR;

}

int main(int argc, char **argv) {

  SpiceDouble topographicSpherical[3];


  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (int i=1554962400; i<1555048800; i+=600) {
    azalt(301, unix2et(i), 35*rpd_c(), -106*rpd_c(), topographicSpherical);

    printf("%d %f %f %f\n", i, topographicSpherical[0]/rpd_c(), 
	   topographicSpherical[1]/rpd_c(), topographicSpherical[2]);

  }

  return 0;

}
