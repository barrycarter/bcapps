#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

int main(int argc, char **argv) {

  SpiceDouble pos[3], et, lt, state[6], el, normal[3];
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // fixed ITRF93 position of latitude 35.05, longitude -106.5, elevation 0
  georec_c (-106.5*rpd_c(), 35.05*rpd_c(), 0, 6378.140, (6378.140-6356.755)/6378.137, pos);

  // surface normal vector from latitude 35.05, longitude -106.5, elevation 0
  surfnm_c(6378.140,6378.140,6356.755,pos,normal);

  // et at 1900 hours UTC 25 Dec 2015
  str2et_c("2015-12-25 19:00:00 UTC",&et);

  spkcpo_c("Sun", et, "ITRF93", "OBSERVER", "CN+S", pos, "Earth", "ITRF93", state, &lt);

  el = dpr_c()*(halfpi_c() - vsep_c(state, normal));

  printf("EL: %7.4f\n",el);

}

    
