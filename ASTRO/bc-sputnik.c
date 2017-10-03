// attempts to find use conic elements of Sputnik to recreate position

// Source: http://satlist.nl/RAE/RAE1957.doc

// Source: https://archive.org/details/nasa_techdoc_19900066808

// Date/Inclination/Period/SMA/perigeeht/apogeeht/ecc/argperigee
// 1957 Oct 4.8 65.1 96.2 6955 215 939 0.052 58

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
  SpiceDouble earth[3], mu[1], state[6], r, colat, lon;
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
  
  // these variables are for reverse-engineering 




  // the elements of Sputnik's trajectory

  SpiceDouble elts[] = {

    // RP Perifocal distance
    earth[0] + mi2km(215),

    // ECC Eccentricity
    0.052,

    // INC Inclination
    65.1*rpd_c(),

    // LNODE Longitude of the ascending node
    // I think this is 0 by definition
    0,

    // ARGP Argument of periapse
    58*rpd_c(),

    // M0 Mean anomaly at epoch
    // setting this 0 as test, are params missing?
    0,

    // T0 Epoch
    // setting this at 0 as test
    0,

    // MU Gravitational parameter
    mu[0]
  };

  // every 3m for a month?
  for (int i=0; i<=365.2425/12*86400; i+=300) {
    
    // Sputnik location at time i
    conics_c(elts, i, state);

    // spherical version of above
    recsph_c(state, &r, &colat, &lon);

    printf("SPH (mi/deg): %i %f %f %f\n", i, 
	   km2mi(r-earth[0]), 90-colat*dpr_c(), lon*dpr_c());

  }

  //  printf("STATE: %f %f %f, %f %f %f\n", state[0], state[1], state[2],
  //	 state[3], state[4], state[5]);


  //  printf("MU: %f, RADS: %f %f %f\n", mu[0], earth[0], earth[1], earth[2]);
}
