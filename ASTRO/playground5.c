// solve http://astronomy.stackexchange.com/questions/13008/are-there-accurate-equinox-and-solstice-predictions-for-the-distant-past

#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,500000);
  SpiceDouble beg, end, i_start, i_end, et_start, et_end;
  char ftime[200], jtime[200];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // the limits of ITRF93 (per "brief earth_720101_070426.bpc" etc)
  str2et_c("1962 JAN 20 00:00:41.184", &i_start);
  str2et_c("2037 JUL 17 00:01:05.183", &i_end);
  printf("RANGE: %f %f\n",i_start,i_end);

  // and the limits of DE431
  str2et_c("13201 B.C. MAY 07 00:00:41.184", &et_start);
  str2et_c("17191 MAR 01 00:01:07.184", &et_end);

  // because I'm using large time intervals...
  gfstol_c(10.);

  // sun's z position
  void solarzed (SpiceDouble et, SpiceDouble *value) {
    SpiceDouble v[3], lt;

    // using 86400 here for safety too 
    if (et >= i_start+86400 && et <= i_end-86400) {
      spkezp_c(10,et,"ITRF93","CN+S",399,v,&lt);
    } else {
      spkezp_c(10,et,"IAU_EARTH","CN+S",399,v,&lt);
    }

    *value = v[2];
  }

  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		SpiceDouble et, SpiceBoolean * isdecr ) {
    uddc_c( udfuns, et, 10., isdecr );
  }

  // TODO: compare to http://stellafane.org/misc/equinox.html among others
  // TODO: find max and min for solstices
  // NOTE: bumping one day either side to avoid off-the-edge errors
  wninsd_c(et_start+86400, et_end-86400, &cnfine);

  gfuds_c(solarzed,gfdecrx,"LOCMAX",0,0,86400,500000,&cnfine,&result);

  int count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c (&result, i, &beg, &end);

    // compute in "calendar form" and JD form
    et2utc_c(beg, "C", 20, 199, ftime);
    et2utc_c(beg, "J", 20, 199, jtime);
    printf("SUMMER %f %s %s\n", beg, jtime, ftime);
  }

}
