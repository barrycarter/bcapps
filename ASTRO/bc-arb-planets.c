#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#define SIXDEGREES 0.10471975511965977462

// Usage: $0 naif-id-of-planet naif-id-of-planet  naif-id-of-planet  ...

static SpiceInt planets[6];
static SpiceInt planetcount;

// actually declaring entire functions here, not just prototype
double et2jd(double d) {return 2451544.5+d/86400.;}
double unix2et(double d) {return d-946684800.;}

// gfq = function that returns scalar value of interest
void gfq (SpiceDouble et, SpiceDouble * value );
// gfdecrx = function that determines whether gfq is decreasing
void gfdecrx (void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
		 SpiceDouble et, SpiceBoolean * isdecr );

int main( int argc, char **argv ) {

  SpiceInt i,j,count,count2;
  SPICEDOUBLE_CELL(result, 2*MAXWIN);
  SPICEDOUBLE_CELL(result2,2*MAXWIN );
  // I use the two below as windows
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(cnfine2,2);
  // I use this as just a cell
  SPICEDOUBLE_CELL(cell,2);
  SpiceDouble beg, end, beg2, end2;

  // fill the static planets array
  for (i=1; i<argc; i++) {planets[i] = atoi(argv[i]);}
  planetcount = argc-1;

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // DE431 limits
  //  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1970 to 2038 (all "Unix time") for testing
  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

  // find under 6 degrees...
  gfuds_c(gfq,gfdecrx,"<",SIXDEGREES,0.,86400.,MAXWIN,&cnfine,&result);
  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("6deg %f %f\n",et2jd(beg),et2jd(end));

    // TODO: this is hideous coding (append/remove, must be a better way)
    //    appndd_c(beg,&cnfine2);
    //    appndd_c(end,&cnfine2);
    //    wnvald_c(2,2,&cnfine2);
    
    wninsd_c(beg,end,&cnfine2);

    printf("SIZE1: %d\n",card_c(&cnfine2));

    // find min *separations* (maybe more than one!) in this window
    gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine2,&result2);
    count2 = wncard_c(&result2);

    for (j=0; j<count2; j++) {
      wnfetd_c(&result2,j,&beg2,&end2);
      // this is cheating, but I'm not using &end, so...
      gfq(beg,&end);
      // TODO: compute minimal solar distance
      printf ("%f %f\n",et2jd(beg2),end2/pi_c()*180.);
    }

    removd_c(beg,&cnfine2);
    removd_c(end,&cnfine2);
    printf("SIZE2: %d\n",card_c(&cnfine2));

  }
  return 0;
}

void gfq ( SpiceDouble et, SpiceDouble *value ) {

  // max separation between all non-0 planets in planets
  // TODO: get min solar separation (not necessarily here)
  SpiceInt i,j;
  SpiceDouble sep, lt;
  SpiceDouble position[planetcount][2];

  // compute the Earth positions first for efficiency
  for (i=1; i<=planetcount; i++) {
    spkezp_c(planets[i], et, "J2000", "LT+S", 399, position[i], &lt);
  }

  *value = 0;

  // and now the angle diffs (keep only min)
  for (i=1; i<=planetcount; i++) {
    for (j=i+1; j<=planetcount; j++) {
      sep = vsep_c(position[i],position[j]);
      if (sep>*value) {*value=sep;}
    }
  }
  return;
}
 
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
	      SpiceDouble et, SpiceBoolean * isdecr ) {
 SpiceDouble dt = 10.;
 uddc_c( udfuns, et, dt, isdecr );
 return;
}

