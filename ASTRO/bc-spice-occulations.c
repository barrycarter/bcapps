#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

#define MAXWIN 10000
#define STRLENGTH 32

// Usage: $0 moon=observer sun=lightsource planet=shadower syear eyear

int main(int argc, char **argv) {

  // variables we will use

  SpiceChar moonFrame[STRLENGTH], planetFrame[STRLENGTH], sunFrame[STRLENGTH], moonName[STRLENGTH], planetName[STRLENGTH], sunName[STRLENGTH];
  SpiceInt moonFrameID, planetFrameID, sunFrameID; 
  SpiceBoolean found;
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);


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

  // TODO: 3600?

  gfoclt_c("ANY", planetName, "ELLIPSOID", planetFrame, sunName, "ELLIPSOID", sunFrame, "LT", moonName, 3600, &cnfine, &result);

    SpiceInt nres = wncard_c(&result);
    SpiceDouble beg, end;
    SpiceDouble planetPos[3], sunPos[3], lt;

    for (int i=0; i<nres; i++) {

      wnfetd_c(&result, i, &beg, &end);

      // get positions
      spkezp_c(planetID, beg, "J2000", "CN+S", moonID, planetPos, &lt);
      spkezp_c(sunID, beg, "J2000", "CN+S", moonID, sunPos, &lt);

      printf("ANGLE: %f\n", vsep_c(planetPos, sunPos)/pi_c()*180);
      printf("%d %d %d %f %f %f %f\n", moonID, sunID, planetID, et2unix(beg), et2unix(end), beg, end);
    }
}

  /*

  //  cnmfrm_c(planet, STRLENGTH, &obscuringCode, planetFrame, &obscuringFound);

  // find start and et

  syear = year2et(syear);
  eyear = year2et(eyear);

  // radii of observer, obscured, obscuring

  bodvrd_c(observer, "RADII", 3, &dim, tempRad);
  observerRad = tempRad[0];
  bods2c_c(observer, &observerID, &observerFound);
  
  bodvrd_c(obscured, "RADII", 3, &dim, tempRad);
  obscuredRad = tempRad[0];
  bods2c_c(obscured, &obscuredID, &obscuredFound);

  bodvrd_c(obscuring, "RADII", 3, &dim, tempRad);
  obscuringRad = tempRad[0];
  bods2c_c(obscuring, &obscuringID, &obscuringFound);

  printf("OBSERVER: R=%f ID=%d\n", observerRad, observerID);
  printf("OBSCURING: R=%f ID=%d FRAME=%s\n", obscuringRad, obscuringID, obscuringFrame);
  printf("OBSCURED: R=%f ID=%d FRAME=%s\n", obscuredRad, obscuredID, obscuredFrame);

  // TODO: do not treat observer as single point

  wninsd_c(syear, eyear, &cnfine);

  gfoclt_c("ANY", obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, 3600, &cnfine, &result);

  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end;

  // ocltid: 
  // 0 = No occultation or transit: both objects are completely visible to the observer.
  // 1 = Partial occultation of second target by first target.
  // 2 = Annular occultation of second target by first.
  // 3 = Total occultation of second target by first.

  for (int i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);

    printf("<minCornerEclipse>\n");
    minCornerEclipse(beg, obscuredID, obscuringID, observerID);
    minCornerEclipse((beg+end)/2, obscuredID, obscuringID, observerID);
    minCornerEclipse(end, obscuredID, obscuringID, observerID);
    printf("/<minCornerEclipse>\n");

    occult_c(obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, beg+1, &ocltid1);

    occult_c(obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, end-1, &ocltid3);

    occult_c(obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, (beg+end)/2, &ocltid2);

    spkezp_c(obscuringID, beg+1, "J2000", "CN+S", observerID, obscuringPos, &lt);
    spkezp_c(obscuredID, beg+1, "J2000", "CN+S", observerID, obscuredPos, &lt);
    ang1 = vsep_c(obscuringPos, obscuredPos);

    printf("TESTB: %f vs %f\n", separationData(obscuredPos, obscuredRad, obscuringPos, obscuringRad), dpr_c()*ang1);

    perpVector(observerRad, obscuredPos, tempRad);

    printf("RESULT: %f %f %f %f\n", tempRad[0], tempRad[1], tempRad[2], vnorm_c(tempRad));

    recsph_c(obscuringPos, &r1, &colat1, &lon1);
    recsph_c(obscuredPos, &r2, &colat2, &lon2);
    printf("OBSCURING: %f %f %f, OBSCURED: %f %f %f\n", r1, 90-colat1*dpr_c(), lon1*dpr_c(), r2, 90-colat2*dpr_c(), lon2*dpr_c());

    spkezp_c(obscuringID, (beg+end)/2, "J2000", "CN+S", observerID, obscuringPos, &lt);
    spkezp_c(obscuredID, (beg+end)/2, "J2000", "CN+S", observerID, obscuredPos, &lt);
    ang2 = vsep_c(obscuringPos, obscuredPos);

    printf("TESTD: %f vs %f\n", separationData(obscuredPos, obscuredRad, obscuringPos, obscuringRad), dpr_c()*ang1);

    recsph_c(obscuringPos, &r1, &colat1, &lon1);
    recsph_c(obscuredPos, &r2, &colat2, &lon2);
    printf("OBSCURING: %f %f %f, OBSCURED: %f %f %f\n", r1, 90-colat1*dpr_c(), lon1*dpr_c(), r2, 90-colat2*dpr_c(), lon2*dpr_c());

    spkezp_c(obscuringID, end-1, "J2000", "CN+S", observerID, obscuringPos, &lt);
    spkezp_c(obscuredID, end-1, "J2000", "CN+S", observerID, obscuredPos, &lt);
    ang3 = vsep_c(obscuringPos, obscuredPos);

    printf("TESTA: %f vs %f\n", separationData(obscuredPos, obscuredRad, obscuringPos, obscuringRad), dpr_c()*ang1);

    recsph_c(obscuringPos, &r1, &colat1, &lon1);
    recsph_c(obscuredPos, &r2, &colat2, &lon2);
    printf("OBSCURING: %f %f %f, OBSCURED: %f %f %f\n", r1, 90-colat1*dpr_c(), lon1*dpr_c(), r2, 90-colat2*dpr_c(), lon2*dpr_c());

    printf("%f %f %d %d %d %f %f %f\n", et2unix(beg), et2unix(end), ocltid1, ocltid2, ocltid3, ang1*dpr_c(), ang2*dpr_c(), ang3*dpr_c());
  }
	    	    
}

  */

/*

values for Jupiter blocking Sun as viewed from Io

gfoclt_c ( "ANY", 599, "ELLIPSOID", "IAU_JUPITER", 10,
 "ELLIPSOID", "IAU_SUN", "XCN", 501, 1, 


cnfine window for input time limit it 2019


result = result window


*/



/*
   void gfoclt_c ( ConstSpiceChar   * occtyp,
                   ConstSpiceChar   * front,
                   ConstSpiceChar   * fshape,
                   ConstSpiceChar   * fframe,
                   ConstSpiceChar   * back,
                   ConstSpiceChar   * bshape,
                   ConstSpiceChar   * bframe,
                   ConstSpiceChar   * abcorr,
                   ConstSpiceChar   * obsrvr,
                   SpiceDouble        step,
                   SpiceCell        * cnfine,
                   SpiceCell        * result )

*/

