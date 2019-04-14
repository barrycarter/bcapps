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

// experimenting w/ possibly faster ways of finding next/last events

// the time between et1 and et2 where target reaches elevation (last
// or first depending on flag), or 0 if no such value exists

SpiceDouble timeRangeElevation(SpiceInt target, SpiceDouble et1,
			       SpiceDouble et2, SpiceDouble elev,
			       SpiceDouble lat, SpiceDouble lon,
			       SpiceInt firstOrLast) {
  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(result, 6);
  SpiceDouble beg, end;

  printf("SIZE: %d\n", wncard_c(&result));

  printf("ET: %f %f, ELEV: %f\n", et1, et2, elev);

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    printf("RETURNING %f\n", altitude(target, et, lat, lon));
    *value = altitude(target, et, lat, lon);
  }

  wninsd_c(et1, et2, &cnfine);

  gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 60., 1000, &cnfine, &result);

  printf("SIZE: %d\n", wncard_c(&result));
  

  // if no results, indicate so
  if (wncard_c(&result) == 0) {return 0;}

  if (firstOrLast == 1) {
      wnfetd_c(&result, 0, &beg, &end);
      return beg;
  } else if (firstOrLast==-1) {
    wnfetd_c(&result, wncard_c(&result)-1, &beg, &end);
      return beg;
  } else {
    return 0;
  }
}

// returns the next time (after et) target reaches elevation elev at lat/lon

SpiceDouble nextTime2(SpiceInt target, SpiceDouble et, SpiceDouble elev, SpiceDouble lat, SpiceDouble lon) {

  // just 1 result cell and cnfine has to be 2 big for beg and end
  SPICEDOUBLE_CELL(cnfine, 1000);
  SPICEDOUBLE_CELL(result, 1000);
  SpiceDouble beg, end;

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // the initial window
  wninsd_c(et, et+86400, &cnfine);

  // loop for 400 days but early abort
  for (int i=0; i<400; i++) {

    // search within that window
    gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 60., 1000, &cnfine, &result);

    // if at least 1 result, break out of for loop
    if (wncard_c(&result) >= 1) {break;}

    // otherwise, tweak window to be next day
    wncond_c(86400., 0., &cnfine);
    wnexpd_c(0., 86400., &cnfine);

  }

  // return the one result
  wnfetd_c(&result, 0, &beg, &end);
  return beg;

}

SpiceDouble prevTime2(SpiceInt target, SpiceDouble et, SpiceDouble elev, SpiceDouble lat, SpiceDouble lon) {

  printf("START FINDING\n");

  // just 1 result cell and cnfine has to be 2 big for beg and end
  SPICEDOUBLE_CELL(cnfine, 1000);
  SPICEDOUBLE_CELL(result, 1000);
  SpiceDouble beg, end;

  // elevation function
  void elevationFunction(SpiceDouble et, SpiceDouble *value) {
    *value = altitude(target, et, lat, lon);
  }

  // create a single large window?
  //  wninsd_c(et-86400*400, et+86400*400, &cnfine);
  wninsd_c(et-86400*400, et, &cnfine);

  gfuds_c(elevationFunction, isDecreasing, "=", elev, 0., 43200., 1000, &cnfine, &result);

  printf("DONE FINDING\n");

  wnfetd_c(&result, wncard_c(&result)-1, &beg, &end);
  return beg;

  // the initial window
  wninsd_c(et-86400, et, &cnfine);


  // loop for 400 days but early abort
  for (int i=-1; i>-400; i--) {

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
  double result;

  double elvs[4] = {-0.83333333333, -6, -12, -18};

  printf("SUN az: %f, el: %f\n", azimuth(10, et, lat, lon)/rpd_c(), 
	 altitude(10, et, lat, lon)/rpd_c());

  printf("MOON az: %f, el: %f\n", azimuth(301, et, lat, lon)/rpd_c(), 
	 altitude(301, et, lat, lon)/rpd_c());

  for (int i=0; i <= 3; i++) {

    for (int j=0; j < 400; j++) {
      printf("J = %d\n", j);
      result = timeRangeElevation(10, et+j*86400, et+(j+1)*86400, elvs[i]*rpd_c(),
				  lat, lon, 1);
      if (result > 0) {break;}
    }

    printf("RESULT: %f\n", et2unix(result));

  }
    
    /*
    printf("CALLING\n");
    printf("SUN PREV @%f: %f\n", elvs[i], et2unix(prevTime2(10, et, elvs[i]*rpd_c(), lat, lon)));
    printf("CALLED\n");
    //    printf("SUN NEXT @%f: %f\n", elvs[i], et2unix(nextTime2(10, et, elvs[i]*rpd_c(), lat, lon)));
  }

  printf("MOON PREV AT HORIZON: %f\n", et2unix(prevTime2(301, et, elvs[0]*rpd_c(), lat, lon)));

  //  printf("MOON NEXT AT HORIZON: %f\n", et2unix(nextTime2(301, et, elvs[0]*rpd_c(), lat, lon)));

  */

  return 0;

}
