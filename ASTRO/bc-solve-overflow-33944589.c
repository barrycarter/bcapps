#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,500000);
  SpiceDouble beg, end, et_start, et_end, lt, iss[3];
  char stime[255];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // the limits of my TLE
  // TODO: compute this automatically from BSP file
  et_start = 506092496.;
  et_end = 507411908.;

  // geocentric angular distance between ISS and moon (transits)
  void issmoon (SpiceDouble et, SpiceDouble *value) {
    SpiceDouble iss[3], moon[3], lt;

    spkezp_c(-125544,et,"J2000","CN+S",399,iss,&lt);
    spkezp_c(301,et,"J2000","CN+S",399,moon,&lt);
    //    printf("%f -> %f\n", et, vsep_c(iss,moon)*dpr_c());
    *value = vsep_c(iss,moon);
  }

  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
                SpiceDouble et, SpiceBoolean * isdecr ) {
    uddc_c( udfuns, et, 10., isdecr );
  }

  // using two day window, but not accurate for those buffer times
  // wninsd_c(et_start+86400.*2, et_end-86400.*2, &cnfine);

  // test
  wninsd_c(et_start+86400.*2, et_start+86400.*4, &cnfine);

  gfuds_c(issmoon,gfdecrx,"LOCMIN",0,0,10.,500000,&cnfine,&result);

  int count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c (&result, i, &beg, &end);
    // below is completely hideous/improper use of end variable
    issmoon(beg, &end);
    spkezp_c(-125544,beg,"J2000","CN+S",399,iss,&lt);
    timout_c(beg, "YYYY-MM-DD HR:MN:SC ::MCAL",255,stime);
    printf("CLOSEST %s %f %f\n", stime, end*dpr_c(), vnorm_c(iss));
  }
}
