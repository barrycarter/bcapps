#include "/home/user/BCGIT/ASTRO/bclib.h"

// TODO: special case for -pi/2? (maybe if dec <= -90 return OCTANS?)

// TODO: currently, viewer must be on Earth, allow non-geocentric

// Usage: $0 planet syear eyear

int main(int argc, char **argv) {

  SPICEDOUBLE_CELL (cnfine, 10000);
  SPICEDOUBLE_CELL (result, 10000);

  SpiceDouble beg, end;

  // check for correct number or arguments and assign to strings
  if (argc != 4) {
    printf("Usage: %s planet syear eyear\n", argv[0]);
    exit(-1);
  }

  // read arguments into variables
  SpiceInt naif = atoi(argv[1]);
  SpiceDouble syear = atof(argv[2]);
  SpiceDouble eyear = atof(argv[3]);

  wninsd_c (year2et(syear), year2et(eyear), &cnfine);

  double interval = 3600;

  // millisecond tolerance is excessive (and causes problems)
  gfstol_c(1.);

  void changed (void (*udfunc) (SpiceDouble et, SpiceDouble *value), 
		SpiceDouble et, SpiceBoolean *xbool) {
    *xbool = (obj2ConstellationNumber(naif, et) != obj2ConstellationNumber(naif, et+interval));
  }

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  gfudb_c(udf_c, changed, interval/2, &cnfine, &result);

    SpiceInt nres = wncard_c(&result);

for (int i=0; i<nres; i++) {

    wnfetd_c(&result,i,&beg,&end);

        printf("%d %f %f %s %s %s %s \n", naif, beg, end, 
	       stardate(beg), stardate(end), 
	       constellationName(obj2ConstellationNumber(naif, beg)), 
	       constellationName(obj2ConstellationNumber(naif, end+interval)));
 }

  return 0;
}

