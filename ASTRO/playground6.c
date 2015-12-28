// determine when a given object is between two given elevations for a
// given location; this is primarily for sun and moon rise
// calculations, since most other objects have virtually 0 angular width

// for this functional version, angles are in radians, elevation in m
// stime, etime: start and end Unix times
// direction = "<" or ">", whether elevation above/below desire

// START TESTING

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// END TESTING

SpiceDouble *bc_between (double latitude, double longitude, double elevation,
			 double stime, double etime, char *target, double low,
			 double high) {

  static SpiceDouble beg, end, results[10000];
  
  // TODO: compute this more efficiently?
  SPICEDOUBLE_CELL(result, 10000);
  SPICEDOUBLE_CELL(cnfine,2);
  wninsd_c(stime, etime, &cnfine);

  // define gfq for geometry finder (nested functions ok per gcc)
  void gfq ( void (*udfuns) (SpiceDouble et, SpiceDouble  *value ),
	     SpiceDouble unixtime, SpiceBoolean * xbool ) {

    double elev=bc_sky_elev(latitude, longitude, elevation, unixtime, target);

    *xbool = (elev>=low && elev<=high);
  }

  // and now the geometry finder
  // TODO: is 3600 below excessive or too small?
  gfudb_c(udf_c, gfq, 1, &cnfine, &result);

  SpiceInt count = wncard_c(&result); 

  for (int i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    results[i*2] = beg;
    results[i*2+1] = end;
  }

  return results;
}

int main(void) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  double *res = bc_between(35.05*rpd_c(), -106.5*rpd_c(), 0,
			   1451272526-86400, 1451272526+86400, "Sun",
			   -5/6.*rpd_c(), -3/10.*rpd_c());

  for (int i=0; i<5; i++) {
    printf("%f %f\n", res[2*i], res[2*i+1]);
  }

  return 0;
}
