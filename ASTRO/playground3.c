/* IAU_EARTH should equal J2000 at the epoch, but not before or after */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main (int argc, char **argv) {

  SpiceDouble delta, lt, v[3], t=0;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  deltet_c(0,"ET",&delta);
  spkezp_c(299,t+delta,"ITRF93","LT+S",399,v,&lt);
  printf("ITRF93: %f %f %f\n",v[0],v[1],v[2]);

  return 0;
}
