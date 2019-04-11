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
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  double et = unix2et(1555022362);
  double lat =  35.05*rpd_c();
  double lon = -106.5*rpd_c();

  double elvs[4] = {-0.83333333333, -6, -12, -18};

  for (int i=0; i <= 3; i++) {
    printf("SUN NEXT @%f: %f\n", elvs[i], et2unix(nextTime(10, et, elvs[i]*rpd_c(), lat, lon)));
  }

  printf("MOON NEXT AT HORIZON: %f\n", et2unix(nextTime(301, et, elvs[0]*rpd_c(), lat, lon)));

  return 0;

}

