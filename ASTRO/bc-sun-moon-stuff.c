/* determines moon/sun rise/set/twilight times */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// slow test case is:
// bc-sun-moon-stuff `calc -89-37/60` `calc -10-11/60` 1404194400

// returns the next time (after et) target reaches elevation elev at lat/lon

SpiceDouble nextTime2(SpiceInt target, SpiceDouble et, SpiceDouble elev, SpiceDouble lat, SpiceDouble lon) {

  // just 1 result cell and cnfine has to be 2 big for beg and end
  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(result, 4);
  SpiceDouble beg, end;

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // the initial window
  //  wninsd_c(et, et+86400, &cnfine);

  // loop for 400 days but early abort
  for (int i=0; i<400; i++) {

    // printf("NEXTTIME2: %d\n", i);

  // BUG?: must resize windows each time called
  ssize_c(2, &cnfine);
  wninsd_c(et+86400*i, et+86400*(i+1), &cnfine);
  ssize_c(6, &result);


    // search within that window
    gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 3600., 1000, &cnfine, &result);

    // if at least 1 result, break out of for loop
    if (wncard_c(&result) >= 1) {break;}

    // otherwise, tweak window to be next day
    // TODO: this is ugly
    //    wncond_c(86400., 0., &cnfine);
    //    wnexpd_c(0., 86400., &cnfine);

  }

  // return the one result
  wnfetd_c(&result, 0, &beg, &end);
  return beg;

}

SpiceDouble prevTime2(SpiceInt target, SpiceDouble et, SpiceDouble elev, SpiceDouble lat, SpiceDouble lon) {

  // just 1 result cell and cnfine has to be 2 big for beg and end
  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(result, 4);
  SpiceDouble beg, end;

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // the initial window
  // TODO: could probably put this inside loop
  wninsd_c(et-86400, et, &cnfine);

  // loop for 400 days but early abort
  for (int i=-1; i>-400; i--) {

  // BUG?: must resize windows each time called
  ssize_c(2, &cnfine);
  ssize_c(4, &result);

    // search within that window
    gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 60., 1000, &cnfine, &result);

    // if at least 1 result, break out of for loop
    if (wncard_c(&result) >= 1) {break;}

    // otherwise, tweak window to be prev dat
    wncond_c(0., 86400., &cnfine);
    wnexpd_c(86400., 0., &cnfine);

  }

  // return the one result
  wnfetd_c(&result, wncard_c(&result)-1, &beg, &end);
  return beg;
}

int main(int argc, char **argv) {
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  if (argc != 4) {
    printf("Usage: lat(degrees) lon(degrees) unixtime\n");
    return -1;
  }

  double lat = atof(argv[1])*rpd_c();
  double lon = atof(argv[2])*rpd_c();
  double et = unix2et(atof(argv[3]));

  double elvs[4] = {-0.83333333333, -6, -12, -18};

  printf("SUN az: %f, el: %f\n", azimuth(10, et, lat, lon)/rpd_c(), 
	 altitude(10, et, lat, lon)/rpd_c());

  printf("MOON az: %f, el: %f\n", azimuth(301, et, lat, lon)/rpd_c(), 
	 altitude(301, et, lat, lon)/rpd_c());

  
  for (int i=0; i <= 3; i++) {
    //    printf("SUN PREV @%f: %f\n", elvs[i], et2unix(prevTime2(10, et, elvs[i]*rpd_c(), lat, lon)));
    printf("SUN NEXT @%f: %f\n", elvs[i], et2unix(nextTime2(10, et, elvs[i]*rpd_c(), lat, lon)));
  }

  //  printf("MOON PREV AT HORIZON: %f\n", et2unix(prevTime2(301, et, elvs[0]*rpd_c(), lat, lon)));

  printf("MOON NEXT AT HORIZON: %f\n", et2unix(nextTime2(301, et, elvs[0]*rpd_c(), lat, lon)));

  return 0;

}

