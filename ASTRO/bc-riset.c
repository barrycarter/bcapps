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
#define MAXWIN 1000000

// globals

double lat, lon, elev, utime, desired;
int target;
char s[5000];

void show_results (char *prefix, SpiceCell result, 
                   void(* udfuns)(SpiceDouble et,SpiceDouble * value)) {

  SpiceInt i;
  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end, vbeg, vend;

  for (i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    udfuns(beg,&vbeg);
    udfuns(end,&vend);
    printf("%s %f %f %f %f '%s'\n",prefix,et2jd(beg),et2jd(end),vbeg,vend,s);
  }
}

void gfq (SpiceDouble et, SpiceDouble *value) {

  SpiceDouble pos[3], v[3], lt;

  // position of point on IAU_EARTH
  georec_c (lon*rpd_c(), lat*rpd_c(), elev, EER, (EER-EPR)/EER, pos);

  // target position (in IAU_EARTH)
  spkezp_c(target,et,"IAU_EARTH","LT",399,v,&lt);

  // and the angle (radians)
  *value = vsep_c(v,pos);

  // debugging
  printf("%f %f\n",et,*value);

}

void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  SpiceDouble dt = 10.;
  uddc_c( udfuns, et, dt, isdecr );
  return;
}

int main(int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  if (argc != 7) {
    // elevation in meters, of location
    printf("Usage: latitude longitude elevation unixtime target desired\n");
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
  desired = atoi(argv[6]);

  wninsd_c(unix2et(utime),unix2et(utime+86400),&cnfine);

  // search for when object at desired altitude (astronomical)
  gfuds_c(gfq,gfdecrx,"=",desired*rpd_c(),0,60,MAXWIN,&cnfine,&result);

  show_results("test",result,gfq);

  //  printf("INPUT: %f %f %f %f %d\n",lat,lon,elev,utime,target);
  //  gfq(unix2et(utime),&ang);
  //  printf("%f\n",r2d(ang));

  return 0;

}
