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

#define MAXWIN 200000

int main(int argc, char **argv) {

  SPICEDOUBLE_CELL(result, 2*MAXWIN);
  SPICEDOUBLE_CELL(cnfine,2);
  SpiceDouble beg, end;
  SpiceInt count = 20;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  SpiceDouble fixedlat = 35.05*rpd_c();
  SpiceDouble fixedlon = -106.5*rpd_c();

  void testf1(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(301, et, fixedlat, fixedlon);
  }

  void testf1Delta (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		    SpiceDouble et, SpiceBoolean * isdecr ) {
    SpiceDouble dt = 10.;
    uddc_c( udfuns, et, dt, isdecr);
  }

  // 1970 to 2038 (all "Unix time") for testing
  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

  gfuds_c(testf1, testf1Delta, "<", 0., 0., 1., MAXWIN, &cnfine,&result);

  for (int i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("0deg %f %f\n",et2jd(beg),et2jd(end));

    // findmins(beg,end);
  }

  //  printf("%f\n", testf1(unix2et(1554962400)));

  /*
  for (int i=1554962400; i<1555048800; i+=600) {
    //    azimuthAltitude(301, unix2et(i), 35*rpd_c(), -106*rpd_c(), topographicSpherical);

    //    printf("%d %f %f %f\n", i, topographicSpherical[0]/rpd_c(), 
    // topographicSpherical[1]/rpd_c(), topographicSpherical[2]);

  printf("ALT: %d %f %f\n", i, 
	 azimuth(301, unix2et(i), 35*rpd_c(), -106*rpd_c())/rpd_c(), 
	 altitude(301, unix2et(i), 35*rpd_c(), -106*rpd_c())/rpd_c());

  }
  */

  return 0;

}
