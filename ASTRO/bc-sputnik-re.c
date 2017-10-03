// Reverse engineer Sputnik's conic elements from https://archive.org/details/nasa_techdoc_19900066808

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

  // variables
  SpiceDouble earth[3], mu[1], pos1[6], pos2[3], elts[SPICE_OSCLTX_NELTS];
  SpiceInt dim;

  // the standard kernels
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // Earth's mass parameter
  bodvrd_c("EARTH", "GM", 1, &dim, mu);

  // Earth's radii
  // TODO: don't assume equitorial as I do below
  bodvrd_c("EARTH", "RADII", 3, &dim, earth);

  // computing Sputnik trajectory attempt from two given values
  // format: rad above earth (mi), lat, lon
  // TODO: does not include Earth rotation for those 3m, but should
  // 5 13 30 1 332.26 39.83 -79.75
  // 5 13 33 1 371.55 30.18 -73.39
  
  // rectangular coords
  sphrec_c(mi2km(332.26)+earth[0], 90-39.83*rpd_c(), -79.75*rpd_c(), pos1);
  sphrec_c(mi2km(371.55)+earth[0], 90-30.18*rpd_c(), -73.39*rpd_c(), pos2);

  // add velocity to pos1 (180 seconds)
  pos1[3] = (pos2[0]-pos1[0])/180;
  pos1[4] = (pos2[1]-pos1[1])/180;
  pos1[5] = (pos2[2]-pos1[2])/180;

  // compute elements
  oscltx_c(pos1, 0, mu[0], elts);

  printf("RP: %f, ECC: %f, INC: %f, LNODE: %f, ARGP: %f, M0: %f, T0: %f, MU: %f, NU: %f, A: %f, TAU: %f\n", 
	 km2mi(elts[0]-earth[0]), elts[1], elts[2]*dpr_c(),
	 elts[3]*dpr_c(), elts[4]*dpr_c(), elts[5]*dpr_c(), elts[6], elts[7], 
	 elts[8]*dpr_c(), km2mi(elts[9]), elts[10]/60);
}
