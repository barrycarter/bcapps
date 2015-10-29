/* Confirm IAU_EARTH is a rotating frame and use it to find sunset/sunrise trivially for now */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SpiceDouble lt;
  SpiceDouble v[3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  spkezp_c(10,0,"IAU_EARTH","NONE",399,v,&lt);
  printf("%f %f %f\n",v[0],v[1],v[2]);

  spkezp_c(10,3600,"IAU_EARTH","NONE",399,v,&lt);
  printf("%f %f %f\n",v[0],v[1],v[2]);

  return 0;

}
