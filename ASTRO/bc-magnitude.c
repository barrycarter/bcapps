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

  SpiceDouble lightpos[3], observerpos[3], lt, albedo, viewedRads[3];
  SpiceChar viewedString[50], observerString[50], lightString[50];
  SpiceInt dim;

  // find positions of light and observer from viewed
  spkezp_c(viewed, et, "J2000", "CN+S", light, lightpos, &lt);
  spkezp_c(viewed, et, "J2000", "CN+S", observer, observerpos, &lt);

  // TODO: get brightness, these will squared
  SpiceDouble lightdist = vnorm_c(lightpos);
  SpiceDouble observerdist = vnorm_c(observerpos);

  // find viewed albedo and radii (need for angular radius)

  bodvcd_c(viewed, "GEOMETRIC_ALBEDO", 1, &dim, &albedo);
  bodvcd_c(viewed, "RADII", 3, &dim, viewedRads);

  // angular radius from observer (of viewed)

  double angRad = asin(viewedRads[0]/observerdist);

  // convert bodies to strings for phase angle function
  sprintf(viewedString, "%d", viewed);
  sprintf(observerString, "%d", observer);
  sprintf(lightString, "%d", light);

  // adjusted due to light distance, angular radius and albedo

  double adj = (angRad*angRad*albedo/lightdist/lightdist)*10e26;
  double magAdj = -5/2*log10(adj);

  // phase angle (pi = new moon, 0 = full moon)

  SpiceDouble phaseAngle = phaseq_c(et, viewedString, lightString, observerString, "CN+S");

  printf("{%f, %f}, \n", phaseAngle, magAdj);

  //  printf("AR: %f, LD: %f, OD: %f, AL: %f, PA: %f, ADJ: %f\n", angRad*dpr_c(), lightdist, observerdist, albedo, phaseAngle, adj);


  // TODO: angular diameter, not just distance

  //  printf("U: %f, LIGHT: %f, OBS: %f, ALB: %f, R: %f, VS: %s PA: %f\n", et2unix(et), lightdist, observerdist, albedo, viewedRads[0], viewedString, phaseAngle);

  return 9999999999999;

}

int main( int argc, char **argv ) {

  // the kernels
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  // albedos
  furnsh_c("/home/user/BCGIT/ASTRO/bc-albedos.tpc");

  for (int i=0; i<366; i++) {
    //    lambertianMagnitude(unix2et(946684800+i*86400), 10, 399, 301);
    lambertianMagnitude(unix2et(946684800+i*86400), 10, 399, 599);
  }

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

