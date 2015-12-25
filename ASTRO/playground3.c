/* IAU_EARTH should equal J2000 at the epoch, but not before or after */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SpiceDouble delta, lt, v[3], t=0;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // test that I got directions right

  printf("UNIX2ET(0): %f\n",unix2et(0));
  printf("ET2UNIX(above): %f\n",et2unix(unix2et(0)));
  printf("ET2UNIX(0): %f\n",et2unix(0));
  printf("UNIX2ET(above): %f\n",unix2et(et2unix(0)));
  exit(0);


  deltet_c(0,"ET",&delta);
  spkezp_c(299,t+delta,"ITRF93","LT+S",399,v,&lt);
  printf("ITRF93: %f %f %f\n",v[0],v[1],v[2]);

  return 0;
}
