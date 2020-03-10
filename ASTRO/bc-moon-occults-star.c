#include "bclib.h"
#include "bc-hygdata.h"
#define MAXWIN 200000

// $0 viewer occulter syear eyear

// TODO: retrograde motion

// TODO: choose good skip value based on input object (eg, Moon = 10
// days, Mars = 100 days?)

int main(int argc, char **argv) {

  // handle the arguments

  if (argc != 5) {
    printf("Usage: %s viewer occulter syear eyear\n", argv[0]);
    exit(-1);
  }

  SpiceInt viewer = atoi(argv[1]);
  SpiceInt occulter = atoi(argv[2]);
  double syear = atof(argv[3]);
  double eyear = atof(argv[4]);

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // find radius of viewer and occulter
  SpiceInt dim;
  SpiceDouble occulterRs[3], viewerRs[3];

  bodvcd_c(viewer, "RADII", 3, &dim, viewerRs);
  bodvcd_c(occulter, "RADII", 3, &dim, occulterRs);

  SpiceDouble occulterR = occulterRs[0];
  SpiceDouble viewerR = viewerRs[0];

  SPICEDOUBLE_CELL(cnfine, MAXWIN);
  SPICEDOUBLE_CELL(result, MAXWIN);

  wninsd_c(year2et(syear), year2et(eyear), &cnfine);

  SpiceInt i;

  void gfq (SpiceDouble et, SpiceDouble *value) {

    // TODO: starpos should be adjusted for proper motion

    // position of the ith star (i is set in main loop but is global)
    SpiceDouble starPos[3] = {hygdata[i][3], hygdata[i][4], hygdata[i][5]};

    // must be J2000 below because starpos are in J2000
    SpiceDouble occulterPos[3], lt;
    spkezp_c(occulter, et, "J2000", "CN+S", viewer, occulterPos, &lt);

    // distance between viewer and occulter (center to center)
    SpiceDouble dist = vnorm_c(occulterPos);

    // angular radius of occulter (assumes occulterR is global var)
    SpiceDouble angRadOcculter = asin(occulterR/dist);

    // parallax based on viewer (assumes viewerR is global var)
    SpiceDouble angRadViewer = asin(viewerR/dist);

    // angular distance adjusted for occulter and viewer radii
    *value = vsep_c(occulterPos, starPos)-angRadOcculter-angRadViewer;
  }

    for (i=0; i<2865; i++) {

      // TODO: reset result after each result
      gfuds_c(gfq, isDecreasing, "LOCMIN", 0, 0, 86400*5, MAXWIN, &cnfine, &result);
      int count = wncard_c(&result);

  for (int j=0; j<count; j++) {

    double beg, end, sep;

    wnfetd_c (&result, j, &beg, &end);
    gfq(beg, &sep);
    printf("%d %d %f %f %f %f\n", i, count, et2unix(beg), sep, hygdata[i][1], hygdata[i][0]);
  }

    }
  return 0;
}

