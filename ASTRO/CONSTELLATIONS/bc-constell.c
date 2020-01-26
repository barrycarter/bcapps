#include "/home/user/BCGIT/ASTRO/bclib.h"

// TODO: special case for -pi/2? (maybe if dec <= -90 return OCTANS?)

int main(int argc, char **argv) {

  SPICEDOUBLE_CELL (cnfine, 10000);
  SPICEDOUBLE_CELL (result, 10000);

  SpiceDouble beg, end;

  wninsd_c (year2et(2020), year2et(2021), &cnfine);

  // char name[100], oldname[100];

  int naif = 301;

  double interval = 3600;

  void changed (void (*udfunc) (SpiceDouble et, SpiceDouble *value), 
		SpiceDouble et, SpiceBoolean *xbool) {

    //    printf("ET: %f, SD: %s %s, OLD: %s, NEW: %s\n", et, stardate(et), 
    //	   stardate(et+interval),
    //	   constellationName(obj2ConstellationNumber(naif, et)),
    //	   constellationName(obj2ConstellationNumber(naif, et+interval)));

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

  /*
  for (double et = year2et(2020); et < year2et(2021); et += 60) {

    strcpy(name, constellationName(obj2ConstellationNumber(naif, et)));

    if (strcmp(name, oldname)) {
      printf("%s %d %s\n", stardate(et), naif, name);
      strcpy(oldname, name);
    }
  }
  */

  return 0;
}

