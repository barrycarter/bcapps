// solve http://astronomy.stackexchange.com/questions/13008/are-there-accurate-equinox-and-solstice-predictions-for-the-distant-past

#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,500000);
  SpiceDouble beg, end, et_start, et_end;
  char ftime[255];

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // and the limits of DE431
  str2et_c("13201 B.C. MAY 07 00:00:41.184", &et_start);
  str2et_c("17091 MAY 07 00:00:41.184", &et_end);

  // because I'm using large time intervals...
  gfstol_c(10.);

  // sun's x or y position (v[1] = y pos = 0 on equinox)
  void solarzed (SpiceDouble et, SpiceDouble *value) {
    SpiceDouble v[3], lt;

    spkezp_c(10,et,"EQEQDATE","CN+S",399,v,&lt);
    *value = v[0];
  }

  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		SpiceDouble et, SpiceBoolean * isdecr ) {
    uddc_c( udfuns, et, 10., isdecr );
  }

  // TODO: compare to http://stellafane.org/misc/equinox.html among others
  // NOTE: bumping one day either side to avoid off-the-edge errors
  wninsd_c(et_start+86400, et_end-86400, &cnfine);

  gfuds_c(solarzed,gfdecrx,"=",0,0,86400,500000,&cnfine,&result);

  int count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c (&result, i, &beg, &end);
    timout_c(beg, "ERA YYYY##-MM-DD HR:MN:SC ::MCAL",255,ftime);
    printf("EQU %f %s\n", beg, ftime);
  }
}
