#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// hardcoding start/end times per planet (bad idea, but...)
#define STIME 315569520.
#define ETIME 631139040.

// Usage: $0 moon1 moon2

int moon1, moon2, extra;

// the radii of the Sun and moon2, needed for multiple subroutines so global
double srad, mrad, sangrad, mangrad;

// the angular distance from moon2 to sun as viewed from moon1 (not symmetric)

void gfq ( SpiceDouble et, SpiceDouble *value ) {
  SpiceDouble pos1[3], pos2[3], lt;

  // moon1 and moon2 should be declared globally
  spkezp_c(moon2, et, "J2000", "CN+S", moon1, pos1, &lt);
  spkezp_c(10, et, "J2000", "CN+S", moon1, pos2, &lt);

  // this is really ugly: since gfq cant return any values, it sets
  // global variables for the sun and moon2's angular radii if the
  // global variable extra is set

  if (extra) {
    sangrad = 2*atan(srad/vnorm_c(pos2));
    mangrad = 2*atan(mrad/vnorm_c(pos1));
  }

  // if moon is further away, not an eclipse/transit
  if (vnorm_c(pos1) > vnorm_c(pos2)) {
    *value = pi_c();
  } else {
    *value = vsep_c(pos1,pos2);
  }
}

void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  SpiceDouble dt = 10.;
  uddc_c( udfuns, et, dt, isdecr );
  return;
}

int main( int argc, char **argv ) {

  SPICEDOUBLE_CELL(result, 200000);
  SPICEDOUBLE_CELL(cnfine, 2);
  SpiceInt i, count, n;
  SpiceChar stime[255];
  SpiceDouble beg, end, ang, temp[3];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // running this just once to get coverage
  // spkcov_c ("/home/barrycarter/SPICE/KERNELS/jup310.bsp", 502, &cnfine);
  spkcov_c ("/home/barrycarter/BCGIT/ASTRO/standard.tm", 502, &cnfine);


  // the moons
  moon1 = atoi(argv[1]);
  moon2 = atoi(argv[2]);

  // diameter of Sun and moon2 (we'll use equatorial radii in our calcs)
  bodvcd_c(10, "RADII", 3, &n, temp);
  srad = temp[0];
  bodvcd_c(moon2, "RADII", 3, &n, temp);
  mrad = temp[0];

  // testing only!
  // wninsd_c(year2et(2010),year2et(2020),&cnfine);
  wninsd_c(STIME+86400.,ETIME-86400.,&cnfine);

  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,3600.,200000,&cnfine,&result);
  count = wncard_c(&result); 

  // for printing, we want the extra values
  extra = 1;

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);

    // angle between sun and moon2
    gfq(beg,&ang);
    
    // consider not printing if less than 6 degrees or something

    timout_c(beg, "ERA YYYY##-MM-DD HR:MN:SC ::MCAL",255,stime);
    printf("%f %f %f %f %f %s\n", beg, ang*dpr_c(), sangrad*dpr_c(),
	   mangrad*dpr_c(), mangrad/sangrad, stime);
  }

  return 0;
}

