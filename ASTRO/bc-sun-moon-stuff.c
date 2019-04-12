/* determines moon/sun rise/set/twilight times */

// the angular separation from zenith of a given body at a given time
// in a given place; because I plan to feed this routine to gfq, most
// "parameters" are global

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main(int argc, char **argv) {
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  double et = unix2et(1555022362);
  double lat =  35.05*rpd_c();
  double lon = -106.5*rpd_c();
  double elvs[4] = {-0.83333333333, -6, -12, -18};

  printf("SUN az: %f, el: %f\n", azimuth(10, et, lat, lon)/rpd_c(), 
	 altitude(10, et, lat, lon)/rpd_c());

  printf("MOON az: %f, el: %f\n", azimuth(301, et, lat, lon)/rpd_c(), 
	 altitude(301, et, lat, lon)/rpd_c());

  for (int i=0; i <= 3; i++) {
    printf("SUN PREV @%f: %f\n", elvs[i], et2unix(prevTime(10, et, elvs[i]*rpd_c(), lat, lon)));
    printf("SUN NEXT @%f: %f\n", elvs[i], et2unix(nextTime(10, et, elvs[i]*rpd_c(), lat, lon)));
  }

  printf("MOON PREV AT HORIZON: %f\n", et2unix(prevTime(301, et, elvs[0]*rpd_c(), lat, lon)));

  printf("MOON NEXT AT HORIZON: %f\n", et2unix(nextTime(301, et, elvs[0]*rpd_c(), lat, lon)));

  return 0;

}

