// Solve http://astronomy.stackexchange.com/questions/12940/22nd-is-shortest-day-in-some-places-but-the-21st-is-shortest-in-other-places-c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main(void) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  double *results = bcriset(30*rpd_c(),0*rpd_c(), 0, 1448953200, 1454310000,
			    "Sun", -5/6.*rpd_c(), ">");

  // this is weird because I don't know actual size of results?
  for (int i=0; i<=100; i++) {
    if (results[2*i] < .001) {break;}

    // this is: time of noon and length of day
    printf("%f %f %f %f\n",30.,0.,
	   (results[2*i]+results[2*i+1])/2, results[2*i+1]-results[2*i]);
  }

  return 0;
}

