// An attempt to functionalize bc-riset.c with corrections to match HORIZONS

// START: just for testing

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// END: just for testing (but see other section)

// for this functional version, angles are in radians, elevation in m
// stime, etime: start and end Unix times
// direction = "<" or ">", whether elevation above/below desire

SpiceDouble *bcriset (double latitude, double longitude, double elevation,
		double stime, double etime, char *target, double desired, 
		char *direction) {

  static SpiceDouble beg, end, results[10000];
  
  // TODO: compute this more efficiently, assuming no more than n
  // rises/day?
  SPICEDOUBLE_CELL(result, 10000);
  SPICEDOUBLE_CELL(cnfine,2);
  wninsd_c(stime, etime, &cnfine);

  // define gfq for geometry finder (nested functions ok per gcc)
  void gfq (SpiceDouble unixtime, SpiceDouble *value) {
    *value = bc_sky_elev(latitude, longitude, elevation, unixtime, target);
  }

  // TODO: this is silly and semi-pointless
  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		SpiceDouble et, SpiceBoolean * isdecr ) {
    SpiceDouble dt = 10.;
    uddc_c(udfuns, et, dt, isdecr);
    return;
  }
    
  // and now the geometry finder
  // TODO: is 3600 below excessive?
  gfuds_c(gfq, gfdecrx, direction, desired, 0, 60, 10000, &cnfine, &result);

  // TODO: don't print results, return them as an array

  SpiceInt count = wncard_c(&result); 

  for (int i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    results[i*2] = beg;
    results[i*2+1] = end;
  }

  // TODO: actually return something useful
  return results;
}

// entire main subroutine is just for testing

int main(void) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  //  bcriset(35.05*rpd_c(), -106.5*rpd_c(), 0, 1451070000-86400,
  //  	  1451070000+86400, "Sun", -5/6.*rpd_c(), "<");

  //  bcriset(35.05*rpd_c(), -106.5*rpd_c(), 0, 1398924000-86400,
  //  	  1398924000+86400, "Sun", -5/6.*rpd_c(), "<");

  bcriset(-71.9244790753479*rpd_c(), -90.3495091977422*rpd_c(), 0, 1398924000-86400,
  	  1398924000+86400, "Sun", -5/6.*rpd_c(), "<");

  //  printf("TEST: %f\n",dpr_c()*bc_sky_elev(35.05*rpd_c(), -106.5*rpd_c(), 0, 1451070000, "Sun"));

  return 0;
}

