#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/user/BCGIT/ASTRO/bclib.h"

#define TIMLEN 41
#define TIMFMT "YYYY-MON-DD HR:MN ::MCAL ::RND"

/**

Given the following:

  - et: the ephemeris time
  - light: the NAIF id of a light emitting source (eg, the Sun)
  - observer: the NAIF id of an observer (barycenter)
  - viewed: the NAIF id of the object being viewed

Returns: not really the magnitude at time et but something useful (TODO: real docs here)

*/

SpiceDouble lambertianMagnitude(SpiceDouble et, SpiceInt light, SpiceInt observer, SpiceInt viewed) {

  SpiceDouble lightpos[3], observerpos[3], lt, albedo;
  SpiceInt dim;

  // find positions of light and observer from viewer
  spkezp_c(viewed, et, "J2000", "CN+S", light, lightpos, &lt);
  spkezp_c(viewed, et, "J2000", "CN+S", observer, observerpos, &lt);

  // find viewer albedo and radii (need for angular radius)

  bodvcd_c(viewed, "ALBEDO", 1, &dim, &albedo);

  // TODO: get albedo, these will squared

  SpiceDouble lightdist = vnorm_c(lightpos);
  SpiceDouble observerdist = vnorm_c(observerpos);

  // TODO: angular diameter, not just distance

  printf("LIGHT: %f, OBS: %f, ALB: %f\n", lightdist, observerdist, albedo);

  return 9999999999999;

}

int main( int argc, char **argv ) {

  // the kernels
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  lambertianMagnitude(0, 10, 399, 301);

  printf("TESTING\n");
  exit(-1);

  // vars from argv
  SpiceChar *target = argv[1];

  // other variables
  SpiceDouble et, phase, lt, earth[3], tpos[3], stdist, etdist;
  SpiceChar begstr[TIMLEN];

  // the call

  // need exact match to magnitude file, so exactly 36525 lines
  for (long i=1; i <= 36525; i++) {

    // the et = i days past 1999 Dec 31 (1 = 2000 Jan 01)
    et = unix2et(946684800)+86400*(i-1);

    // distance of target from Earth/Sun requires finding pos of both wrt Sun
    // ref frame is irrelevant since we just want distance

    spkpos_c("Earth", et, "J2000", "CN+S", "Sun", earth, &lt);
    spkpos_c(target, et, "J2000", "CN+S", "Sun", tpos, &lt);

    // distances
    stdist = vnorm_c(tpos);
    etdist = vdist_c(earth, tpos);

    // pretty print of this et
    timout_c (et, TIMFMT, TIMLEN, begstr);

    // and the phase
    phase = phaseq_c(et, target, "Sun", "Earth", "CN+S");

    printf("%s,%s,%li,%f,%f,%f\n", target, begstr, i, phase, stdist, etdist);
  }
}

