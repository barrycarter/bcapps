/* determines moon/sun rise/set/twilight times */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

// slow test case is:
// bc-sun-moon-stuff `calc -89-37/60` `calc -10-11/60` 1404194400

int main(int argc, char **argv) {
  furnsh_c("/home/user/BCGIT/ASTRO/standard-reduced.tm");

  if (argc != 4) {
    printf("Usage: lat(degrees) lon(degrees) unixtime\n");
    return -1;
  }

  // testing
  double (*f)(SpiceInt, SpiceDouble, SpiceDouble, SpiceDouble, SpiceDouble, SpiceInt) = &prevOrNextTime;

  double lat = atof(argv[1])*rpd_c();
  double lon = atof(argv[2])*rpd_c();
  double et = unix2et(atof(argv[3]));

  double elvs[4] = {-0.83333333333, -6, -12, -18};

  // out format is for other progs (could kill the newlines, but nah)

  printf("saz=%f&sel=%f&\n", azimuth(10, et, lat, lon)/rpd_c(), 
	 altitude(10, et, lat, lon)/rpd_c());

  printf("maz=%f&mel=%f&\n", azimuth(301, et, lat, lon)/rpd_c(), 
	 altitude(301, et, lat, lon)/rpd_c());

  
  for (int i=0; i <= 3; i++) {
    printf("sp%f=%f&\n", elvs[i], et2unix(f(10, et, elvs[i]*rpd_c(), lat, lon, -1)));
    printf("sn%f=%f&\n", elvs[i], et2unix(f(10, et, elvs[i]*rpd_c(), lat, lon, 1)));
  }

  printf("mph=%f&\n", et2unix(f(301, et, elvs[0]*rpd_c(), lat, lon, -1)));

  printf("mnh=%f\n", et2unix(f(301, et, elvs[0]*rpd_c(), lat, lon, 1)));

  return 0;

}

