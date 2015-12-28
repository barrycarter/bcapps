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

double bcriset (double latitude, double longitude, double elevation, double unixtime, int target, double desire) {

  SpiceDouble radii[3], pos[3], normal[3];
  SpiceInt n;

  // the Earth's equatorial and polar radii
  bodvrd_c ( "EARTH", "RADII", 3, &n, radii );

  // position of latitude/longitude/elevation on ellipsoid
  georec_c (longitude, latitude, elevation/1000., radii[0],
	    (radii[0]-radii[2])/radii[0], pos);

  // surface normal vector to ellipsoid at latitude/longitude (this is
  // NOT the same as pos!)

  surfnm_c(radii[0],radii[1],radii[2],pos,normal);

  // define gfq for geometry finder (nested functions ok per gcc)
  void gfq (SpiceDouble et, SpiceDouble *value) {
    SpiceDouble state[6], lt;
    
    // target position at ET et (not UTC)
    // TODO: don't hardcode Sun (but yikes, no object id?)

    spkcpo_c("Sun", et, "ITRF93", "OBSERVER", "CN+S", pos, "Earth", "ITRF93",
	     state,  &lt);

    *value = halfpi_c() - vsep_c(state,normal);
  }

  // TODO: actually return something useful
  return 0;
}

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

  // TODO: vsep_c below uses first 3 members of state, should I be
  // more careful here?

  return halfpi_c() - vsep_c(state,normal);
}

// entire main subroutine is just for testing

int main(void) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  printf("TEST: %f\n",dpr_c()*bc_sky_elev(35.05*rpd_c(), -106.5*rpd_c(), 0, 1451070000, "Sun"));

  return 0;
}

