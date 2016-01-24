#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"

// Usage: $0 naif-id-of-planet naif-id-of-planet  naif-id-of-planet  ...

static SpiceInt planets[6];
static int planetcount;

void gfq ( SpiceDouble et, SpiceDouble *value ) {

  printf("GFQ CALLED: %f, pc is: %d\n",et,planetcount);

  // max separation between all non-0 planets in planets
  int i,j;
  SpiceDouble sep, lt, max=0.;
  SpiceDouble position[planetcount+1][3];
  // TODO: why do I need a temp var here?
  SpiceDouble temp[3];

  // compute positions
  for (i=1; i<=planetcount; i++) {
    spkezp_c(planets[i], et, "J2000", "LT+S", 10, temp, &lt);
    // copy from temp var (argh!)
    for (j=0; j<=2; j++) {position[i][j] = temp[j];}
  }


  // and now the angle diffs (keep only min)
  for (i=1; i<=planetcount; i++) {
    for (j=i+1; j<=planetcount; j++) {
      printf("J: %d\n",j);
      sep = vsep_c(position[i],position[j]);
      if (sep>max) {max=sep;}
    }
  }

  *value=max;
  return;
}
 
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
	      SpiceDouble et, SpiceBoolean * isdecr ) {
 SpiceDouble dt = 10.;
 uddc_c( udfuns, et, dt, isdecr );
 return;
}

// Finds and prints (icky) local mins of gfq between beg and end

void findmins(SpiceDouble beg, SpiceDouble end) {

  // we expect very few conjunctions per 6 degree interval, 100 is overkill
  SPICEDOUBLE_CELL(result2, 200);
  SPICEDOUBLE_CELL(cnfine2,2);
  SpiceDouble beg2, end2;
  SpiceInt count,i;
  // TODO: if intervals are bad minwise, expand them and trim?
  wninsd_c(beg,end,&cnfine2);
  // find local mins
  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine2,&result2);
  count = wncard_c(&result2); 
  for (i=0; i<count; i++) {
    wnfetd_c(&result2,i,&beg2,&end2);
    printf("min %f %f\n",et2jd(beg2),et2jd(end2));
  }

  // SPICEDOUBLE_CELLs are static (as per SpiceCel.h, so must clear)
  removd_c(beg,&cnfine2);
  removd_c(end,&cnfine2);
  return;
}

int main( int argc, char **argv ) {

  SpiceInt i,count;
  SPICEDOUBLE_CELL(result, 2*MAXWIN);
  SPICEDOUBLE_CELL(cnfine,2);
  SpiceDouble beg, end;

  // fill the static planets array
  for (i=1; i<argc; i++) {planets[i] = atoi(argv[i]);}
  planetcount = argc-1;

  printf("PLANETS: %d %d %d %d\n",planets[0],planets[1],planets[2],planetcount);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // DE431 limits
  //  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1970 to 2038 (all "Unix time") for testing
  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

  // find under 6 degrees...
  gfuds_c(gfq,gfdecrx,"<",6.*rpd_c(),0.,86400.,MAXWIN,&cnfine,&result);
  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("6deg %f %f\n",et2jd(beg),et2jd(end));
    findmins(beg,end);
  }
  return 0;
}

