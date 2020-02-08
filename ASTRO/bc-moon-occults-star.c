#include "bclib.h"
#include "bc-hygdata.h"
#include EARTH_RADIUS 6371009/1000.
#include MOON_RADIUS 1738.1

int main(int argc, char **argv) {

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  double et = unix2et(1581115950);

  double moonpos[3], starpos[3], lt;

  void gfq (SpiceDouble et, SpiceDouble *value) {

    spkezp_c(301, et, "J2000", "CN+S", 399, moonpos, &lt);
    double angsep = asin((EARTH_RADIUS + MOON_RADIUS)/vnorm_c(moonpos));

    

  }


  //  printf("MOONPOS: %f %f %f\n", moonpos[0], moonpos[1], moonpos[2]);

  for (double j = et; j < et+86400*366; j+= 3600) {

    for (int i=0; i<2865; i++) {

      // TODO: add proper motion
      starpos[0] = hygdata[i][3];
      starpos[1] = hygdata[i][4];
      starpos[2] = hygdata[i][5];

      double sep = vsep_c(moonpos, starpos);

    if (sep < 1./150) {
      printf("%f %f %f %f\n", et2unix(j), hygdata[i][0], vsep_c(moonpos, starpos), hygdata[i][1]);
    }
    }
  }
  return -1;
}

// angle is Sin[(er + mr)/em]
