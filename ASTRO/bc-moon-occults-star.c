#include "bclib.h"
#include "bc-hygdata.h"
#define EARTH_RADIUS 6371009/1000.
#define MOON_RADIUS 1738.1
#define MAXWIN 20000


int main(int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  SPICEDOUBLE_CELL(cnfine, MAXWIN);
  SPICEDOUBLE_CELL(result, MAXWIN);

  wninsd_c(year2et(2020), year2et(2021), &cnfine);

  int chosen;

  double moonpos[3], starpos[3], lt;

  void gfq (SpiceDouble et, SpiceDouble *value) {

    spkezp_c(301, et, "J2000", "CN+S", 399, moonpos, &lt);
    double angsep = asin((EARTH_RADIUS + MOON_RADIUS)/vnorm_c(moonpos));
    double minsep = 2;

    for (int i=0; i<2865; i++) {

      // TODO: add proper motion
      starpos[0] = hygdata[i][3];
      starpos[1] = hygdata[i][4];
      starpos[2] = hygdata[i][5];

      double sep = vsep_c(moonpos, starpos)/angsep;
      if (sep < minsep) {
	minsep = sep;
	chosen = i;
      }
    }
    *value = minsep;
  }

  gfuds_c(gfq, isDecreasing, "<", 1., 0, 3600, MAXWIN, &cnfine, &result);
  int count = wncard_c(&result);
  double beg, end;
    
  for (int i=0; i<count; i++) {

    // find the time of event (beg == end in this case)
    wnfetd_c (&result, i, &beg, &end);
    printf("%f %f %d\n", et2unix(beg), et2unix(end), chosen);
  }
  return 0;
}
