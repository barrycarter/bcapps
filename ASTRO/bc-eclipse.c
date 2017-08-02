// determine azimuth/altitude of sun/moon for given earth location
// over period of time

// Usage: lat lon stime etime (latter 2 in unix seconds)

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

  SpiceDouble pos[3];

  // if insufficient argc, complain, don't just seg fault
  if (argc != 5) {
    printf("Usage: lat lon stime etime\n");
    exit(-1);
  }

  double lat = atof(argv[1]);
  double lon = atof(argv[2]);
  double stime = atof(argv[3]);
  double etime = atof(argv[4]);

  // fixed ITRF93 position of lat/lon
  // TODO: pull 6378.140 and 6356.755 from SPICE dont hardcode
  georec_c(lon*rpd_c(), lat*rpd_c(), 0, 6378.140, (6378.140-6356.755)/6378.137, pos);

  printf("POS (%f %f): %f %f %f\n", lat, lon, pos[0], pos[1], pos[2]);

}
