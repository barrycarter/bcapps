#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

#define MAXWIN 10000
#define STRLENGTH 32

// Usage: $0 observer obscured_object obscuring_object syear eyear

int main(int argc, char **argv) {

  // variables we will use

  SpiceChar obscuredFrame[STRLENGTH], obscuringFrame[STRLENGTH];
  SpiceInt obscuredCode, obscuringCode, ocltid1, ocltid2, ocltid3, dim;
  SpiceDouble observerRad, obscuredRad, obscuringRad, tempRad[3], obscuredPos[6], obscuringPos[6], lt, ang1, ang2, ang3, temp1[3], temp2[3];
  SpiceBoolean obscuredFound, obscuringFound;
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);


  // check for correct number or arguments and assign to strings

  if (argc != 6) {
    printf("Usage: %s observer obscured_object obscuring_object syear eyear\n", argv[0]);
    exit(-1);
  }

  SpiceChar *observer = argv[1];
  SpiceChar *obscured = argv[2];
  SpiceChar *obscuring = argv[3];
  SpiceDouble syear = atof(argv[4]);
  SpiceDouble eyear = atof(argv[5]);

  printf("PARAMS: %s %s %s %f %f\n", observer, obscured, obscuring, syear, eyear);

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // determine frames for obscured and obscuring

  cnmfrm_c(obscured, STRLENGTH, &obscuredCode, obscuredFrame, &obscuredFound);
  cnmfrm_c(obscuring, STRLENGTH, &obscuringCode, obscuringFrame, &obscuringFound);

  printf("OBSCURED: %s\n", obscuredFrame);
  printf("OBSCURING: %s\n", obscuringFrame);

  // find start and et

  syear = year2et(syear);
  eyear = year2et(eyear);

  // radii of observer, obscured, obscuring

  bodvrd_c(observer, "RADII", 3, &dim, tempRad);
  observerRad = tempRad[0];

  bodvrd_c(obscured, "RADII", 3, &dim, tempRad);
  obscuredRad = tempRad[0];

  bodvrd_c(obscuring, "RADII", 3, &dim, tempRad);
  obscuringRad = tempRad[0];

  printf("VIEWER, SUN, BLOCKER: %f %f %f\n", observerRad, obscuredRad, obscuringRad);

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

    occult_c(obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, beg+1, &ocltid1);

    occult_c(obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, end-1, &ocltid3);

    occult_c(obscuring, "ELLIPSOID", obscuringFrame, obscured, "ELLIPSOID", obscuredFrame, "XCN", observer, (beg+end)/2, &ocltid2);

    spkezr_c(obscuring, beg+1, obscuringFrame, "CN+S", observer, obscuringPos, &lt);
    spkezr_c(obscured, beg+1, obscuredFrame, "CN+S", observer, obscuredPos, &lt);
    //    ang1 = vsep_c(obscuringPos, obscuredPos);

    temp1[0] = obscuringPos[0];
    temp1[1] = obscuringPos[1];
    temp1[2] = obscuringPos[2];

    temp2[0] = obscuredPos[0];
    temp2[1] = obscuredPos[1];
    temp2[2] = obscuredPos[2];

    ang1 = vsep_c(temp1, temp2);

    printf("ANG1: %f %f %f / %f %f %f\n", obscuringPos[0], obscuringPos[1], obscuringPos[2], obscuredPos[0], obscuredPos[1], obscuredPos[2]);

    spkezr_c(obscuring, (beg+end)/2, obscuringFrame, "CN+S", observer, obscuringPos, &lt);
    spkezr_c(obscured, (beg+end)/2, obscuredFrame, "CN+S", observer, obscuredPos, &lt);
    ang2 = vsep_c(obscuringPos, obscuredPos);

    printf("ANG2: %f %f %f / %f %f %f\n", obscuringPos[0], obscuringPos[1], obscuringPos[2], obscuredPos[0], obscuredPos[1], obscuredPos[2]);

    spkezr_c(obscuring, end-1, obscuringFrame, "CN+S", observer, obscuringPos, &lt);
    spkezr_c(obscured, end-1, obscuredFrame, "CN+S", observer, obscuredPos, &lt);
    ang3 = vsep_c(obscuringPos, obscuredPos);

    printf("ANG3: %f %f %f / %f %f %f\n", obscuringPos[0], obscuringPos[1], obscuringPos[2], obscuredPos[0], obscuredPos[1], obscuredPos[2]);

    printf("%f %f %d %d %d %f %f %f\n", et2unix(beg), et2unix(end), ocltid1, ocltid2, ocltid3, ang1*dpr_c(), ang2*dpr_c(), ang3*dpr_c());
  }
	    	    
}

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

