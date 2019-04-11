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

// TODO: add this to bclib.h

void isDecreasing(void(* udfuns)(SpiceDouble et,SpiceDouble *value),
		  SpiceDouble et, SpiceBoolean *isdecr) {
  SpiceDouble res1, res2;
  udfuns(et-1, &res1);
  udfuns(et+1, &res2);
  *isdecr = (res2 < res1);
}

// returns the next time (after et) target reaches elevation elev at lat/lon

SpiceDouble nextTime(SpiceInt target, SpiceDouble et, SpiceDouble elev, SpiceDouble lat, SpiceDouble lon) {

  // just 1 result cell and cnfine has to be 2 big for beg and end
  SPICEDOUBLE_CELL(result, 10);
  SPICEDOUBLE_CELL(cnfine,2);
  SpiceDouble beg, end;

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // loop for 400 days but early abort
  for (int i=0; i<400; i++) {

    // the window for a day
    wninsd_c(et+i*86400, et+(i+1)*86400, &cnfine);

    // search within that window
    gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 60., 10, &cnfine, &result);

    // if at least 1 result, break out of for loop
    if (wncard_c(&result) >= 1) {break;}
  }

  // return the one result
  wnfetd_c(&result, 0, &beg, &end);
  return beg;

}

int main(int argc, char **argv) {

  /*
  SPICEDOUBLE_CELL(result, 10);
  SPICEDOUBLE_CELL(cnfine,2);
  SpiceDouble beg, end;
  */

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  printf("SUNSET: %f\n", et2unix(nextTime(10, unix2et(1555022362), -0.833333*rpd_c(), 35.05*rpd_c(), -106.5*rpd_c())));

  /*
  // we are testing with fixed lat/lon
  SpiceDouble fixedlat = 35.05*rpd_c();
  SpiceDouble fixedlon = -106.5*rpd_c();

  // the function that gives the value we want
  void testf1(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(10, et, fixedlat, fixedlon);
  }

  // today
  wninsd_c(unix2et(1554962400),unix2et(1554962400+86400*1),&cnfine);

  gfuds_c(testf1, isDecreasing, "=", 0., 0., 60., 100, &cnfine,&result);
  SpiceInt count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("0deg %f %f\n",et2unix(beg),et2unix(end));
  }
  */

  return 0;

}

