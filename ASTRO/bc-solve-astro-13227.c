#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,500000);
  SpiceDouble beg, end, et_start, et_end;
  char stime[255], etime[255];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // and the limits of DE431
  str2et_c("13201 B.C. MAY 07 00:00:41.184", &et_start);
  str2et_c("17091 MAY 07 00:00:41.184", &et_end);

  // because I'm using large time intervals...
  gfstol_c(10.);

  // geocentric angular distance between venus and sun (transits)
  void sunven (SpiceDouble et, SpiceDouble *value) {
    SpiceDouble ven[3], sun[3], lt;

    spkezp_c(10,et,"J2000","CN+S",399,sun,&lt);
    spkezp_c(299,et,"J2000","CN+S",399,ven,&lt);

    /* if Venus is further away, return 180 degrees, not a transit */
    if (vnorm_c(ven) > vnorm_c(sun)) {
      *value = pi_c();
    } else {
      *value = vsep_c(sun,ven);
    }
  }

  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
                SpiceDouble et, SpiceBoolean * isdecr ) {
    uddc_c( udfuns, et, 10., isdecr );
  }

  //  wninsd_c(et_start+86400, et_end-86400, &cnfine);

  wninsd_c(0, 86400*366*100., &cnfine);

  gfuds_c(sunven,gfdecrx,"<",0.2666*rpd_c(),0,86400,500000,&cnfine,&result);

  int count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c (&result, i, &beg, &end);
    timout_c(beg, "ERA YYYY##-MM-DD HR:MN:SC ::MCAL",255,stime);
    timout_c(end, "ERA YYYY##-MM-DD HR:MN:SC ::MCAL",255,etime);
    printf("VEN %f %f %s %s\n", beg, end, stime, etime);
  }
}


