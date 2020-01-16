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
  SpiceInt moonID, sunID, planetID;
  SpiceDouble beg, end, beger, ender;
  SpiceBoolean found;
  SPICEDOUBLE_CELL(cnfine, 2);
  SPICEDOUBLE_CELL(cnfiner, 2);
  SPICEDOUBLE_CELL(result, 2*MAXWIN);
  SPICEDOUBLE_CELL(resulter, 2*MAXWIN);

  // check for correct number or arguments and assign to strings
  if (argc != 6) {
    printf("Usage: %s moon=observer sun=lightsource planet=shadower syear eyear\n", argv[0]);
    exit(-1);
  }

  // read arguments into variables
  SpiceChar *moon = argv[1];
  SpiceChar *sun = argv[2];
  SpiceChar *planet = argv[3];
  SpiceDouble syear = atof(argv[4]);
  SpiceDouble eyear = atof(argv[5]);

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // convert sun/moon/planet names into NAIF ids w/ error checking

  bods2c_c(moon, &moonID, &found);
  if (!found) {printf("MOON %s NOT FOUND\n", moon); exit(-1);}

  bods2c_c(sun, &sunID, &found);
  if (!found) {printf("SUN %s NOT FOUND\n", sun); exit(-1);}

  bods2c_c(planet, &planetID, &found);
  if (!found) {printf("PLANET %s NOT FOUND\n", planet); exit(-1);}

  //  spkcov_c("/home/user/SPICE/KERNELS/jup310.bsp", moonID, &result);
  //  wnfetd_c(&result, 0, &beg, &end);
  //  printf("COVERAGE: %f %f %f %f\n", beg, end, et2unix(beg), et2unix(end));

  wninsd_c(year2et(syear), year2et(eyear), &cnfine);

  // defining geometry finder function via given arguments
  // this is for at least a partial lunar eclipse

  void gfq (SpiceDouble et, SpiceDouble *value) {
    *value = penUmbralData(et, sunID, planetID, moonID, 1);
  }

  gfuds_c(gfq, isDecreasing, ">", 0, 0, 60, MAXWIN, &cnfine, &result);

  SpiceInt nres = wncard_c(&result);

  printf("# PARTIAL: %d\n", nres);

  for (int i=0; i<nres; i++) {

    wnfetd_c(&result,i,&beg,&end);

    printf("%d %d %d P+ %f %s\n", moonID, sunID, planetID, beg, stardate(beg));

    // create a window for the partial eclipse to find total eclipse (if any)
    wninsd_c(beg, end, &cnfiner);
    gfuds_c(gfq, isDecreasing, ">", 1, 0, 1, MAXWIN, &cnfiner, &resulter);

    if (wncard_c(&resulter) > 0) {
      wnfetd_c(&resulter, 0, &beger, &ender);
      printf("%d %d %d T+ %f %s\n", moonID, sunID, planetID, beger, stardate(beger));
      printf("%d %d %d T- %f %s\n", moonID, sunID, planetID, ender, stardate(ender));
    }

    printf("%d %d %d P- %f %s\n", moonID, sunID, planetID, end, stardate(end));

    // empty out cell we inserted into earlier
    removd_c(beg,&cnfiner);
    removd_c(end,&cnfiner);
  }
}
