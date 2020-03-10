#include "bclib.h"
#include "bc-hygdata.h"
#define MAXWIN 200000

// $0 viewer barycenter-naif-id-of-planet syear eyear

// max satellite distances for nth planet

maxsat[11] = {0, 2440, 6050, 427320, 23480, 40492246, 36068000, 29552162, 93661806, 340945, 695700};

// angular distance between planet and star #n (in hygdata.h) as
// viewed from observer at time et

SpiceDouble angDistStar(int observer, double et, int planet, int star) {

  // compute position of observer wrt planet

  SpiceDouble pos[3], lt;
  spkezp_c(planet, et, "J2000", "CN+S", observer, pos, &lt);

  // position of star
  SpiceDouble starpos[3] = {hygdata[star][3], hygdata[star][4], hygdata[star][5]};

  // angular distance
  return vsep_c(starpos, pos);
}

int main(int argc, char **argv) {

    if (argc != 5) {
    printf("Usage: %s viewer occulter syear eyear\n", argv[0]);
    exit(-1);
  }

  SpiceChar *viewer = argv[1];
  SpiceChar *occultbc = argv[2];
  double syear = atof(argv[3]);
  double eyear = atof(argv[4]);

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  

  
  


}


