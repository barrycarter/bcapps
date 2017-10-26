// Determine where Mt Fuji's solar shadow hits Earth, if at all

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"


// TODO: move line to bclib.h
// given two points and a parameter t return the point corresponding
// to on the line

void line (double a[3], double b[3], double t, double result[3]) {
  result[0] = a[0]+t*(b[0]-a[0]);
  result[1] = a[1]+t*(b[1]-a[1]);
  result[2] = a[2]+t*(b[2]-a[2]);
  return;
}

// Mt Fuji data: 12,388 ft elevation, 35°21#29#N
// 138°43#52#ECoordinates: 35°21#29#N 138°43#52#E#

// args: none at the moment

int main (int argc, char **argv) {

  // vars
  double pos[3], normal[3], erad[3], mount[3], sun[3], result[3], lt;
  SpiceInt dim = 3;

  // kernel
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // time
  double time = unix2et(1508911200);

  // Mt Fuji (TODO: parametrize)

  // latitude and longitude in radians
  double lat = (35.+21/60.+29/3600.)*rpd_c();
  double lon = (138.+43/60.+52/3600.)*rpd_c();

  // elevation in km
  double geoelev = 12388.*12*2.54/100./1000.;
  
  // erad = radii of Earth (0 and 1 are equatorial, 2 is polar)
  bodvrd_c("EARTH", "RADII", 3, &dim, erad);
  printf("ERAD (%d): %f %f %f\n", dim, erad[0], erad[1], erad[2]);

  // pos = fixed ITRF93 position of lat/lon
  georec_c(lon,lat,0,erad[0],(erad[0]-erad[2])/erad[0], pos);
  printf("POS: %f %f %f\n",pos[0],pos[1],pos[2]);

  // and the surface normal to this location
  surfnm_c(erad[0],erad[1],erad[2],pos,normal);
  printf("SRFNM (%f %f): %f %f %f\n", lat, lon, normal[0], normal[1], normal[2]);

  // multiply surface normal by height
  // TODO: must be better way to do this, not just for loop either
  normal[0]*=geoelev;
  normal[1]*=geoelev;
  normal[2]*=geoelev;
  
  // actual position of mountain in ITRF93
  vadd_c(pos, normal, mount);
  printf("MOUNT: %f %f %f\n",mount[0],mount[1],mount[2]);

  // position of Sun
  spkezr_c("SUN", time, "ITRF93", "CN+S", "EARTH", sun, &lt);
  printf("SUN: %f %f %f\n",sun[0],sun[1],sun[2]);

  // testing
  line(mount, sun, 0.5, result);
  printf("RESULT: %f %f %f\n",result[0],result[1],result[2]);

  printf("TESTING\n");

  return 0;
  // TODO: this ignore refraction which is very important in this case!

  // position of Mt Fuji

}

