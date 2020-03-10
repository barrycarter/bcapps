#include "bclib.h"
#include "bc-hygdata.h"
#define MAXWIN 200000

// $0 viewer barycenter-naif-id-of-planet syear eyear

// max satellite distances for nth planet

double maxsat[11] = {0, 2440, 6050, 427320, 23480, 40492246, 36068000, 29552162, 93661806, 340945, 695700};

// angular distance between planet (given as a single digit
// barycenter) and star #n (in hygdata.h) subtracted by angular radius of
// planet's moon system and viewer parallax as viewed from observer at time et

// TODO: add parallax for viewer

SpiceDouble angDistStar(int observer, double et, int planet, int star) {

  // "cache" the value of observerRadius
  static double observerRadius;

  if (observerRadius < 1e-9) {
    SpiceDouble radii[3];
    SpiceInt dim;
    bodvrd_c(viewer, "RADII", 3, &dim, radii);
    observerRadius = radii[0];
  }


  // compute position of observer wrt planet

  SpiceDouble pos[3], lt;
  spkezp_c(planet*100+99, et, "J2000", "CN+S", observer, pos, &lt);

  // compute angular radius of planet and satellites
  SpiceDouble planSatAngRad = asin(maxsat[planet]/vnorm_c(pos));

  // position of star
  SpiceDouble starpos[3] = {hygdata[star][3], hygdata[star][4], hygdata[star][5]};

  // parallax from viewer
  asin (viewer radius/distance)


  // angular distance
  return vsep_c(starpos, pos)/planSatAngRad;
}

int main(int argc, char **argv) {

  int i;
  double sep;

  if (argc != 5) {
    printf("Usage: %s viewer occulter syear eyear\n", argv[0]);
    exit(-1);
  }

  SpiceInt viewer = atoi(argv[1]);
  SpiceInt occulter = atoi(argv[2]);
  double syear = atof(argv[3]);
  double eyear = atof(argv[4]);
  
  SPICEDOUBLE_CELL(cnfine, MAXWIN);
  SPICEDOUBLE_CELL(result, MAXWIN);
  wninsd_c(year2et(syear), year2et(eyear), &cnfine);
  
  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // declare the gfq function (which will use hardcoded i)

  void gfq (SpiceDouble et, SpiceDouble *value) {
    *value = angDistStar(viewer, et, occulter, i);
  }
  
  double beg, end;
  
  for (i=0; i<2865; i++) {

    gfuds_c(gfq, isDecreasing, "<", 1., 0, 86400*5, MAXWIN, &cnfine, &result);
    int count = wncard_c(&result);

  for (int j=0; j<count; j++) {
    wnfetd_c (&result, j, &beg, &end);
    gfq((beg+end)/2, &sep);
    printf("%f %f %f %f %f\n", et2unix(beg), et2unix(end), sep, hygdata[i][1], hygdata[i][0]);
  }
  }
}



