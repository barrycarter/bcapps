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

// bc_sky_elev either doesn't work right or I forgot how to use my own
// function-- in either case, let's replace it

double bc_elev(double lat, double lon, double et, char *target) {

  double pos[3], radii[3], normal[3], state[3], lt;
  int n;

  // the Earth's 3 radii
  bodvrd_c ("EARTH", "RADII", 3, &n, radii);

  double flat = (radii[2]-radii[0])/radii[0];

  // rectangular coordinates of position (ITRF93)
  georec_c (lon*rpd_c(), lat*rpd_c(), 0, radii[0], flat, pos);

  // surface normal vector to ellipsoid at latitude/longitude (this is
  // NOT the same as pos!)
  surfnm_c(radii[0], radii[1], radii[2], pos, normal);

  // position of Sun in ITRF93
  spkcpo_c("Sun", et, "ITRF93", "OBSERVER", "CN+S", pos, "Earth", "ITRF93", state,  &lt);

  return dpr_c()*(halfpi_c() - vsep_c(state,  normal));
}

int main (int argc, char **argv) {

  double lat, lon, time, elev;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (int i=0; i< 100000; i++) {

    printf("ALPHA\n");

    lat = pi_c()*rand()/RAND_MAX-halfpi_c();
    lon = twopi_c()*rand()/RAND_MAX-pi_c();
    time = 1167721200.*rand()/RAND_MAX + 946684800.;
    //    printf("T = %f\n", time);
    //    elev = bc_sky_elev(5, lat, lon, 0., unix2et(time), "10", 0);

    // failing badly, so testing w/ knownish values
    lat = 0.611738;
    lon = -1.85878;
    time = 1554616800+i;
    elev = bc_elev(lat, lon, unix2et(time), "10");

    printf("%f,%f,%f,%f\n", lat, lon, time, elev);
  }
}

