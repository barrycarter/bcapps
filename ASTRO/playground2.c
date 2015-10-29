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
  SpiceDouble ang;
  SpiceDouble v[3];
  SpiceDouble pos[3];
  int i;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // abq roughly
  georec_c (-106.5*rpd_c(), 35.5*rpd_c(), 1.609344, 6378.137, 
	    (6378.137-6356.7523)/6378.137, pos);

  for (i=0; i<86400; i+=3600) {
    // pos of sun from IAU_EARTH
    spkezp_c(10,i,"IAU_EARTH","NONE",399,v,&lt);

    // angle between abq vector and sun vector (0 = zenith)
    ang = vsep_c (v,pos);

    printf("%d %f\n",i,r2d(ang));
  }

  return 0;

}
