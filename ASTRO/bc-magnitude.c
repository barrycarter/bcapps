#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

#define TIMLEN 41
#define TIMFMT "YYYY-MON-DD HR:MN ::MCAL ::RND"

int main( int argc, char **argv ) {

  // vars from argv
  SpiceChar *target = argv[1];

  // other variables
  SpiceDouble et, phase, lt, earth[3], tpos[3], stdist, etdist;
  SpiceChar begstr[TIMLEN];

  // the kernels
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

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
