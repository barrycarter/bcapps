// solve http://astronomy.stackexchange.com/questions/13008/are-there-accurate-equinox-and-solstice-predictions-for-the-distant-past

#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,10000);
  SpiceDouble beg, end, v[3], lt;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // change error handling
  erract_c("SET", 0, "RETURN");

  // because I'm using large time intervals...
  gfstol_c(10.);

  // because I know I will be seeing errors
  errprt_c ("SET", 0, "NONE");

  // sun's z position
  void solarzed (SpiceDouble et, SpiceDouble *value) {

    // NOTE: trying ITRF93 first and checking for error is
    // inefficient, since ITRF93 only covers a few dozen years; more
    // efficient would be finding the actual times ITRF93 is valid
    // (which the filenames and comments clearly state, although
    // earth_720101_070426.bpc actually goes back to 1963 or so), but
    // I want to show how clever I am with error handling

    // try ITRF93 first
    spkezp_c(10,et,"ITRF93","CN+S",399,v,&lt);

    // I should be checking for a specific error, but this is close enough
    if (failed_c()) {
      // fallback on IAU_EARTH
      spkezp_c(10,et,"IAU_EARTH","CN+S",399,v,&lt);
      // and reset the error message
      reset_c();
      // this printf will let me use a better approach later
      //      printf("NO ITRF93 FOR: %f %f\n",et,et2unix(et));
    } else {
      printf("USING ITRF FOR: %f %f\n",et,et2unix(et));
    }

    *value = v[2];
  }

  void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
		SpiceDouble et, SpiceBoolean * isdecr ) {
    uddc_c( udfuns, et, 10., isdecr );
  }

  // using 1000-3000 for first attempt to compare randomly to
  // http://stellafane.org/misc/equinox.html

  double et_start = -31556217600.;
  double et_end = -31556217600+2000*366*86400.;

  // TODO: find max and min for solstices
  wninsd_c(et_start, et_end,&cnfine);

  gfuds_c(solarzed,gfdecrx,"=",0,0,86400,10000,&cnfine,&result);

  int count = wncard_c( &result );

  for (int i=0; i<count; i++) {
    wnfetd_c (&result, i, &beg, &end);
    printf("%f\n", beg);
  }

}
