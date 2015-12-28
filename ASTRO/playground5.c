// An attempt to functionalize bc-riset.c with corrections to match HORIZONS

// START: just for testing

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// END: just for testing (but see other section)

// determine (sky) elevation of body at given time and place (radians
// and meters) on Earth

double bc_sky_elev (double latitude, double longitude, double elevation, double unixtime, char *target) {

  SpiceDouble radii[3], pos[3], normal[3], state[6], lt;
  SpiceInt n;
  
  // the Earth's equatorial and polar radii
  bodvrd_c("EARTH", "RADII", 3, &n, radii);

  // position of latitude/longitude/elevation on ellipsoid
  georec_c(longitude, latitude, elevation/1000., radii[0], 
	   (radii[0]-radii[2])/radii[0], pos);

  // surface normal vector to ellipsoid at latitude/longitude (this is
  // NOT the same as pos!)
  surfnm_c(radii[0], radii[1], radii[2], pos, normal);

  // find the position
  spkcpo_c(target, unix2et(unixtime), "ITRF93", "OBSERVER", "CN+S", pos, 
	   "Earth", "ITRF93", state,  &lt);

  // debugging
  printf("ELEV(%s) at %f, lat %f, lon %f: %f\n", target, unixtime,
	 latitude*dpr_c(), longitude*dpr_c(), 
	 (halfpi_c() - vsep_c(state,normal))*dpr_c());

  // TODO: vsep_c below uses first 3 members of state, should I be
  // more careful here?

  return halfpi_c() - vsep_c(state,normal);
}

// for this functional version, angles are in radians, elevation in m
// stime, etime: start and end Unix times
// direction = "<" or ">", whether elevation above/below desire

double bcriset (double latitude, double longitude, double elevation,
		double stime, double etime, char *target, double desired, 
		char *direction) {

  SpiceDouble beg, end;
  
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
    printf("%f %f\n",beg,end);
  }

  // TODO: actually return something useful
  return 0;
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

