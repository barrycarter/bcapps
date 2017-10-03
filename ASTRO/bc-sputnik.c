// attempts to find use conic elements of Sputnik to recreate position

// Source: http://satlist.nl/RAE/RAE1957.doc

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

  SpiceDouble earth[3], mu[1];
  SpiceInt dim;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // Earth's mass parameter
  bodvrd_c("EARTH", "GM", 1, &dim, mu);

  // Earth's radii
  // TODO: don't assume equitorial as I do below
  bodvrd_c("EARTH", "RADII", 3, &dim, earth);

  printf("MU: %f, RADS: %f %f %f\n", mu[0], earth[0], earth[1], earth[2]);
}
