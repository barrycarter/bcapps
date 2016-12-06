/*

 Attempts to answer http://astronomy.stackexchange.com/questions/19301/period-of-unique-horoscopes/19306#19306

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"


// the next two includes are part of the CSPICE library
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000

// compute mercury (NAIF 1) ecliptic coords from earth as test
void test (SpiceDouble et, SpiceDouble *value) {

  // array to hold the XYZ and lt results from spkezp_c
  SpiceDouble res[3];
  SpiceDouble lt;

  spkezp_c(1, et, "ECLIPDATE", "LT+S", 399, res, &lt);

  printf("%f -> %f %f %f\n", et, res[0], res[1], res[2]);

  *value = res[2];
}

int main (int argc, char **argv) {

  SpiceDouble v[3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");

  for (int i=0; i<366*86400; i+=86400) {
    test(unix2et(i), v);
  }
}
