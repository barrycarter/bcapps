// http://astronomy.stackexchange.com/questions/5894/is-there-any-point-on-earth-where-the-moon-stays-below-the-horizon-for-an-extend/5898#5898

#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

int main(int argc, char **argv) {

  SPICEDOUBLE_CELL(result, 10000);
  SPICEDOUBLE_CELL(cnfine,2);
  SpiceDouble radii[3], beg, end;
  SpiceInt n;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // the year 2015
  double stime = 1419984000, etime = 1451692800;
  wninsd_c(stime, etime, &cnfine);

  // lat/lon from argv
  double lat = atof(argv[1]), lon = atof(argv[2]);

  // the moon's radii
  bodvrd_c("MOON", "RADII", 3, &n, radii);

  // determines if moon is down at a given time
  void moondown ( void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
             SpiceDouble unixtime, SpiceBoolean * xbool ) {
    *xbool = (bc_sky_elev(6, lat*rpd_c(), lon*rpd_c(), 0., unixtime,
			  "Moon", radii[0])<=-34/60.*rpd_c());
  }

  // we're looking for minimum 1 week down, so 604800. below is ok
  gfudb_c(udf_c, moondown, 604800./5., &cnfine, &result);

  SpiceInt count = wncard_c(&result); 

  // intentionally ignoring first result
  for (int i=1; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("%f %f %f\n",beg,end,end-beg);
  }
  return 0;
}
