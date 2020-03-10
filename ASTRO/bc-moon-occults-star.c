#include "bclib.h"
#include "bc-hygdata.h"
#define MAXWIN 200000

// $0 viewer occulter syear eyear

// TODO: retrograde motion

// TODO: choose good skip value based on input object (eg, Moon = 10
// days, Mars = 100 days?)

// this is a test only

void isDecreasing2(void(* udfuns)(SpiceDouble et,SpiceDouble *value),
		  SpiceDouble et, SpiceBoolean *isdecr) {
  SpiceDouble res1, res2;
  udfuns(et-600, &res1);
  udfuns(et+600, &res2);
//printf("DIFF: %.15f\n", res2-res1);
  *isdecr = (res2 < res1);
}



int main(int argc, char **argv) {

  // handle the arguments

  if (argc != 5) {
    printf("Usage: %s viewer occulter syear eyear\n", argv[0]);
    exit(-1);
  }

  SpiceChar *viewer = argv[1];
  SpiceChar *occulter = argv[2];
  double syear = atof(argv[3]);
  double eyear = atof(argv[4]);

  furnsh_c("/home/user/BCGIT/ASTRO/bc-maxkernel.tm");

  // convert viewer/occulter names into NAIF ids w/ error checking

  SpiceInt viewerID, occulterID;
  SpiceBoolean found;

  bods2c_c(viewer, &viewerID, &found);
  if (!found) {printf("VIEWER %s NOT FOUND\n", viewer); exit(-1);}

  bods2c_c(occulter, &occulterID, &found);
  if (!found) {printf("OCCULTER %s NOT FOUND\n", occulter); exit(-1);}

  // find radius of viewer and occulter
  SpiceInt dim;
  SpiceDouble occulterRs[3], viewerRs[3];

  //  printf("ALPHA: %s %s\n", viewer, occulter);

  bodvrd_c(viewer, "RADII", 3, &dim, viewerRs);
  bodvrd_c(occulter, "RADII", 3, &dim, occulterRs);

  SpiceDouble occulterR = occulterRs[0];
  SpiceDouble viewerR = viewerRs[0];

  SPICEDOUBLE_CELL(cnfine, MAXWIN);
  SPICEDOUBLE_CELL(result, MAXWIN);

  wninsd_c(year2et(syear), year2et(eyear), &cnfine);

  double moonpos[3], starpos[3], r, colat, lon, lt, sep, angsep;

  // NOTE: we use global starpos array here for star position, don't
  // declare new one each time

  void gfq (SpiceDouble et, SpiceDouble *value) {
    spkezp_c(occulterID, et, "J2000", "CN+S", viewerID, moonpos, &lt);
    recsph_c(moonpos, &r, &colat, &lon);

    // line below is experimental
    // double angsep = (occulterR + viewerR)/vnorm_c(moonpos);

    //    angsep = asin((occulterR + viewerR)/vnorm_c(moonpos));
    *value = vsep_c(moonpos, starpos)/asin((occulterR + viewerR)/vnorm_c(moonpos));

    //    printf("MOON: %d %f %f %f %f %f %f %f %f\n", count, et2unix(et), lon/pi_c()*12, (halfpi_c()-colat)/pi_c()*180, r, starpos[0], starpos[1], starpos[2], vsep_c(moonpos, starpos)/pi_c()*180);

  }

  int count, j;
  double beg, end;

    for (int i=0; i<2865; i++) {

      printf("STAR: %d\n", i);

      // TODO: TESTING!!!

      // TODO: add proper motion
      starpos[0] = hygdata[i][3];
      starpos[1] = hygdata[i][4];
      starpos[2] = hygdata[i][5];

      // TODO: reset result after each result
      gfuds_c(gfq, isDecreasing2, "<", 2., 0, 86400*5, MAXWIN, &cnfine, &result);
      count = wncard_c(&result);

  for (j=0; j<count; j++) {
    wnfetd_c (&result, j, &beg, &end);
    gfq((beg+end)/2, &sep);
    printf("%f %f %f %f %f\n", et2unix(beg), et2unix(end), sep, hygdata[i][1], hygdata[i][0]);
  }

    }
  return 0;
}

