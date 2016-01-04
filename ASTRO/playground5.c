// solve http://astronomy.stackexchange.com/questions/13008/are-there-accurate-equinox-and-solstice-predictions-for-the-distant-past

#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,10000);
  SpiceDouble beg, end, v[3], lt;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // this shouldn't work
  printf("%f\n", unix2et(-86400*365.2425*7));
  spkezp_c(10,-1167626622,"ITRF93","CN+S",399,v,&lt);
  printf("%f %f %f\n",v[0],v[1],v[2]);

  // sun's z position
  void solarzed (SpiceDouble unixtime, SpiceDouble *value) {
    SpiceDouble v[3], lt;
    // TODO: can't use ITRF93 here because it doesn't go back far enough
    spkezp_c(10,unix2et(unixtime),"ITRF93","CN+S",399,v,&lt);
    *value = v[2];
  }

  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		SpiceDouble et, SpiceBoolean * isdecr ) {
    uddc_c( udfuns, et, 10., isdecr );
  }

  // find when 0
  wninsd_c(-86400*365.2425*7,1451631600+86400*365.2425*20,&cnfine);
  gfuds_c(solarzed,gfdecrx,"=",0,0,86400,10000,&cnfine,&result);

  int count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c (&result, i, &beg, &end);
    printf("%f\n", beg);
  }

}
