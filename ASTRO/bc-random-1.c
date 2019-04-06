// generates solar altitude at random lats/lons/times to test AI algorithm

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

  double lat, lon, time, elev;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (int i=0; i< 100000; i++) {

    lat = pi_c()*rand()/RAND_MAX-halfpi_c();
    lon = twopi_c()*rand()/RAND_MAX-pi_c();
    time = 1167721200.*rand()/RAND_MAX + 946684800.;
    elev = bc_sky_elev(5, lat, lon, 0., time, "10", 0);
    printf("%f,%f,%f,%f\n", lat, lon, time, elev);
  }
}

