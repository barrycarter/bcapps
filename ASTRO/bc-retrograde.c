/* Compute retrogrades for given planet */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

// TODO: make this a parameter, not a constant

SpiceInt planet = 4;

/* the psuedo-derivative of the ecliptic longitude for global `planet` */

void DEclipLong(SpiceDouble et, SpiceDouble *value) {

  SpiceDouble v[3], lt, lng0, lng1;

  // planet ecliptic longitude at 5 seconds before and after given time

  spkezp_c(planet, et+5, "ECLIPDATE","CN+S", 399, v, &lt);
  lng0 = atan2(v[1], v[0]);

  spkezp_c(planet, et+10, "ECLIPDATE","CN+S", 399, v, &lt);
  lng1 = atan2(v[1], v[0]);

  //  printf("%f %f\n", lng0, lng1);

  // TODO: handle 2pi "wraparound" case

  *value = lng1-lng0;

}

// given a prefix (string), window (collection of intervals) and a
// function, display (print) the value of the function at each
// endpoint of each interval with prefix (which I will use to tell me
// what I am computing)

void show_results (char *prefix, SpiceCell result, 
                   void(* udfuns)(SpiceDouble et,SpiceDouble * value)) {

  SpiceInt i;
  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end, vbeg, vend;

  for (i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    udfuns(beg,&vbeg);
    udfuns(end,&vend);
    printf("%s %f %f %f %f\n",prefix,et2jd(beg),et2jd(end),vbeg,vend);
  }
}

int main (int argc, char **argv) {

  // to hold the results
  SPICEDOUBLE_CELL(result, 200000);
  SPICEDOUBLE_CELL(cnfine, 2);

  // the standard ephemerides

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  /*

  for (double i=year2et(2018); i < year2et(2020); i+=3600) {
    retrogradeQ(i, &test);
    printf("TEST %f %d\n", et2unix(i), test);
  }

  */

  // 1970 to 2038 (all "Unix time") for testing

  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

  gfuds_c(DEclipLong, isDecreasing, "<", 0, 0, 3600., 5000, &cnfine, &result);

  show_results("TESTING", result, DEclipLong);

}

  
