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

  double pos[3], radii[3], normal[3], state[6], lt;
  int n;

  // the Earth's 3 radii
  bodvrd_c ("EARTH", "RADII", 3, &n, radii);

  double flat = (radii[2]-radii[0])/radii[0];

  // rectangular coordinates of position (ITRF93)
  georec_c (lon, lat, 0, radii[0], flat, pos);

  // surface normal vector to ellipsoid at latitude/longitude (this is
  // NOT the same as pos!)
  surfnm_c(radii[0], radii[1], radii[2], pos, normal);

  //  printf("POS: %f %f %f\n", pos[0], pos[1], pos[2]);
  //  printf("NORMAL: %f %f %f\n", normal[0], normal[1], normal[2]);

  printf("ET = %f\n", et);
  printf("POS: %f %f %f\n", pos[0], pos[1], pos[2]);

  // position of Sun in ITRF93
  spkcpo_c("Sun", et, "ITRF93", "OBSERVER", "CN+S", pos, "Earth", "ITRF93", state,  &lt);

  printf("STATE: %f %f %f\n", state[0], state[1], state[2]);

  double el = halfpi_c() - vsep_c(state,  normal); 

  printf("DEBUG: %f,%f,%f,%f,%f\n", lat, lon, 0., el, et);

  //  return halfpi_c() - vsep_c(normal,  state);
  return el;

}

int main (int argc, char **argv) {

  double lat, lon, time;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  for (int i=0; i< 100000; i++) {

    lat = pi_c()*rand()/RAND_MAX-halfpi_c();
    lon = twopi_c()*rand()/RAND_MAX-pi_c();
    time = 1167721200.*rand()/RAND_MAX + 946684800.;

    // failing badly, so testing w/ knownish values
    lat = 0.611738;
    lon = -1.85878;
    time = 1554616800.+i;

    double utime = unix2et(time);
    //    double elev = bc_elev(lat, lon, unix2et(time), "10");
    double elev = bc_elev(lat, lon, unix2et(time), "10");

    printf("%f,%f,%f,%f,%f\n", lat, lon, time, elev, utime);
  }
}

