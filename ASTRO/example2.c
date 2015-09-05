#include <stdio.h>
#include "SpiceUsr.h"

void main(int argc, char **argv) {

#define ET0 -479695089600.+86400*468
#define STEP 86400.0
#define MAXITR 11100016
  SpiceInt i;
  SpiceDouble et, lt, pos [3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  int source = atoi(argv[1]);
  int target = atoi(argv[2]);

  for ( i = 0;  i < MAXITR;  i++ ) {
    et  =  ET0 + i*STEP;
    spkezp_c (target, et, "J2000", "NONE", source,  pos,  &lt);
    printf("%d %d %f %.9f %.9f %.9f\n",source,target,2451545.+et/86400.,pos[0],pos[1],pos[2]);
  }
}
