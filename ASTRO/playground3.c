/* IAU_EARTH should equal J2000 at the epoch, but not before or after */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main (int argc, char **argv) {

  SpiceDouble lt, v[3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/test.tm");
  spkezp_c(10,0,"IAU_EARTH","NONE",399,v,&lt);
  printf("IAU_EARTH: %f %f %f\n",v[0],v[1],v[2]);
  spkezp_c(10,0,"J2000","NONE",399,v,&lt);
  printf("J2000: %f %f %f\n",v[0],v[1],v[2]);
  return 0;
}
