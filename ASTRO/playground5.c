// An attempt to functionalize bc-riset.c with corrections to match HORIZONS

// START: just for testing

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// END: just for testing (but see other section)

// entire main subroutine is just for testing

int main(void) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  //  bcriset(35.05*rpd_c(), -106.5*rpd_c(), 0, 1451070000-86400,
  //  	  1451070000+86400, "Sun", -5/6.*rpd_c(), "<");

  //  bcriset(35.05*rpd_c(), -106.5*rpd_c(), 0, 1398924000-86400,
  //  	  1398924000+86400, "Sun", -5/6.*rpd_c(), "<");

  double *results = bcriset(-71.9244790753479*rpd_c(),
			    -90.3495091977422*rpd_c(), 0, 1398924000-86400*10,
			    1398924000+86400*10, "Sun", -5/6.*rpd_c(), "<");

  // this is weird because I don't know actual size of results?
  for (int i=0; i<=200; i++) {
    printf("RESULT %d: %f\n",i,results[i]);
  }

  //  printf("SIZE: %d\n", sizeof(*results));


  //  printf("TEST: %f\n",dpr_c()*bc_sky_elev(35.05*rpd_c(), -106.5*rpd_c(), 0, 1451070000, "Sun"));

  return 0;
}

