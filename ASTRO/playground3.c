/* IAU_EARTH should equal J2000 at the epoch, but not before or after */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main (int argc, char **argv) {

  // t=19037 is the closest second to the epoch where GMST is 0
  SpiceDouble lt, v[3], t=0;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  spkezp_c(299,t,"IAU_EARTH","NONE",399,v,&lt);
  printf("IAU_EARTH: %f %f %f\n",v[0],v[1],v[2]);
  return 0;
}
