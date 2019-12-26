#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

#define MAXWIN 10000
#define STRLENGTH 32

// Usage: $0 moon sun planet syear eyear

// moon = observer, sun = shinything, planet = blockything

int main(int argc, char **argv) {

  // variables we will use
  SpiceInt moonID, sunID, planetID;
  SpiceDouble beg, end;
  SpiceBoolean found;
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);

  // check for correct number or arguments and assign to strings
  if (argc != 6) {
    printf("Usage: %s moon sun planet syear eyear\n", argv[0]);
    exit(-1);
  }

  // read arguments into variables
  SpiceChar *moon = argv[1];
  SpiceChar *sun = argv[2];
  SpiceChar *planet = argv[3];
  SpiceDouble syear = atof(argv[4]);
  SpiceDouble eyear = atof(argv[5]);

  // convert sun/moon/planet names into NAIF ids w/ error checking

  bods2c_c(moon, &moonID, &found);
  if (!found) {printf("MOON %s NOT FOUND\n", moon); exit(-1);}

  bods2c_c(sun, &sunID, &found);
  if (!found) {printf("SUN %s NOT FOUND\n", sun); exit(-1);}

  bods2c_c(planet, &planetID, &found);
  if (!found) {printf("PLANET %s NOT FOUND\n", planet); exit(-1);}

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // start and end times for window
  wninsd_c(year2et(syear), year2et(eyear), &cnfine);

  // defining geometry finder function via given arguments

  void gfq (SpiceDouble et, SpiceDouble *value) {
    *value = minCornerEclipse(et, sunID, planetID, moonID);
  }

  gfuds_c(gfq, isDecreasing, "<", -1, 0, 3600, MAXWIN, &cnfine, &result);

  SpiceInt nres = wncard_c(&result);

  for (int i=0; i<nres; i++) {

    wnfetd_c(&result,i,&beg,&end);

    eclipseAroundTheWorld((beg+end)/2, sunID, planetID, moonID);

    printf("%f %f %d %d %d\n", et2unix(beg), et2unix(end), moonID, sunID, planetID);
  }
}
