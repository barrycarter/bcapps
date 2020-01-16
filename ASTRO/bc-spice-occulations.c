#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

#define MAXWIN 1000000
#define STRLENGTH 32

// Usage: $0 moon=observer sun=lightsource planet=shadower syear eyear

int main(int argc, char **argv) {

  // variables we will use

  SpiceChar moonFrame[STRLENGTH], planetFrame[STRLENGTH], sunFrame[STRLENGTH], moonName[STRLENGTH], planetName[STRLENGTH], sunName[STRLENGTH];
  SpiceInt moonFrameID, planetFrameID, sunFrameID; 
  SpiceDouble beg, end, beger, ender;
  SpiceBoolean found;
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(cnfiner, 2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);
  SPICEDOUBLE_CELL(resulter, 2*MAXWIN);

  // check for correct number or arguments and assign to strings

  if (argc != 6) {
     printf("Usage: %s moon=observer sun=lightsource planet=shadower syear eyear\n", argv[0]);
    exit(-1);
  }

  SpiceInt moonID = atoi(argv[1]);
  SpiceInt sunID = atoi(argv[2]);
  SpiceInt planetID = atoi(argv[3]);
  SpiceDouble syear = year2et(atof(argv[4]));
  SpiceDouble eyear = year2et(atof(argv[5]));

  wninsd_c(syear, eyear, &cnfine);

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  /// convert parameters to strings, complain if not found

  bodc2n_c(moonID, STRLENGTH, moonName, &found);
  if (!found) {printf("Name for NAIF ID %d not found\n", moonID); exit(-1);}

  bodc2n_c(planetID, STRLENGTH, planetName, &found);
  if (!found) {printf("Name for NAIF ID %d not found\n", planetID); exit(-1);}

  bodc2n_c(sunID, STRLENGTH, sunName, &found);
  if (!found) {printf("Name for NAIF ID %d not found\n", sunID); exit(-1);}

  printf("PARAMS: %d (%s) %d (%s) %d (%s) %f %f\n", moonID, moonName, sunID, sunName, planetID, planetName, syear, eyear);

  // determine frames for obscured and obscuring

  cnmfrm_c(moonName, STRLENGTH, &moonFrameID, moonFrame, &found);
  if (!found) {printf("FRAME NOT FOUND: %d (%s)\n", moonID, moonName); exit(-1);}

  cnmfrm_c(planetName, STRLENGTH, &planetFrameID, planetFrame, &found);
  if (!found) {printf("FRAME NOT FOUND: %d (%s)\n", planetID, planetName); exit(-1);}

  cnmfrm_c(sunName, STRLENGTH, &sunFrameID, sunFrame, &found);
  if (!found) {printf("FRAME NOT FOUND: %d (%s)\n", sunID, sunName); exit(-1);}

  printf("FRAMES: %d (%s) %d (%s) %d (%s)\n", moonFrameID, moonFrame, planetFrameID, planetFrame, sunFrameID, sunFrame);

  gfoclt_c("ANY", planetName, "ELLIPSOID", planetFrame, sunName, "ELLIPSOID", sunFrame, "LT", moonName, 60, &cnfine, &result);

    SpiceInt nres = wncard_c(&result);

    for (int i=0; i<nres; i++) {

      wnfetd_c(&result, i, &beg, &end);

      printf("%d %d %d CP+ %f %s\n", moonID, sunID, planetID, beg, stardate(beg));

    // create a window for the partial eclipse to find total eclipse (if any)
    wninsd_c(beg, end, &cnfiner);
    
    gfoclt_c("FULL", planetName, "ELLIPSOID", planetFrame, sunName, "ELLIPSOID", sunFrame, "LT", moonName, 1, &cnfiner, &resulter);

    if (wncard_c(&resulter) > 0) {
      wnfetd_c(&resulter, 0, &beger, &ender);
      printf("%d %d %d CT+ %f %s\n", moonID, sunID, planetID, beger, stardate(beger));
      printf("%d %d %d CT- %f %s\n", moonID, sunID, planetID, ender, stardate(ender));
    }

    // empty out cell we inserted into earlier
    removd_c(beg,&cnfiner);
    removd_c(end,&cnfiner);

    printf("%d %d %d CP- %f %s\n", moonID, sunID, planetID, end, stardate(end));
    }
}
