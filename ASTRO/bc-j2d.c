// Uses SPICE library to convert SPICE dates (ie, ET) to calendar dates

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"

SpiceChar s[255];

int main( int argc, char **argv ) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  SpiceDouble jd = 1721423.5;

  et2utc_c ((jd-2451545.)*86400, "C", 0, 255, s);
  printf("%s\n",s);

  //  etcal_c((jd-2451545.)*86400.,255,s);
  //  printf("%s\n",s);
}

