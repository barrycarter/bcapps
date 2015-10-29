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

// Earth's equatorial and polar radii
#define EER 6378.137
#define EPR 6356.7523

// globals

double lat, lon, elev, utime;
int target;

void gfq (SpiceDouble et, SpiceDouble *value) {

  SpiceDouble pos[3], v[3], lt;

  // position of point on IAU_EARTH
  georec_c (lon*rpd_c(), lat*rpd_c(), elev, EER, (EER-EPR)/EER, pos);

  // target position (in IAU_EARTH)
  spkezp_c(target,et,"IAU_EARTH","NONE",399,v,&lt);

  printf("ME: %f %f %f %f\n",et,pos[0],pos[1],pos[2]);
  printf("TARG: %f %f %f %f\n",et,v[0],v[1],v[2]);

  // and the angle (radians)
  *value = vsep_c(v,pos);

}

int main(int argc, char **argv) {

  SpiceDouble ang;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  if (argc != 6) {
    printf("Usage: latitude longitude elevation unixtime target\n");
    exit(-1);
  }

  // assign from argv
  lat = atof(argv[1]);
  lon = atof(argv[2]);
  // elevation in km
  elev = atof(argv[3]);
  // fractional unix time is probably silly, but allowing it
  utime = atof(argv[4]);
  target = atoi(argv[5]);

  printf("INPUT: %f %f %f %f %d\n",lat,lon,elev,utime,target);

  gfq(unix2et(utime),&ang);

  printf("%f\n",r2d(ang));

  return 0;

}
