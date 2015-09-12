#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#define SIXDEGREES 0.10471975511965977462

// prototypes
// gfq = function that returns scalar value of interest
void gfq (SpiceDouble et, SpiceDouble * value );
// gfdecrx = function that determines whether gfq is decreasing
void gfdecrx (void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
		 SpiceDouble et, SpiceBoolean * isdecr );
void findmins(SpiceDouble beg, SpiceDouble end);

// Usage: $0 naif-id-of-planet naif-id-of-planet  naif-id-of-planet  ...

static SpiceInt planets[6];
static SpiceInt planetcount;

// actually declaring entire functions here, not just prototype
double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}
double unix2et(double d) {return d-946684800.;}

int main( int argc, char **argv ) {

  SpiceInt i,j,count;
  SPICEDOUBLE_CELL(result, 2*MAXWIN);
  SPICEDOUBLE_CELL(cnfine,2);
  SpiceDouble beg, end;

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

    // findmins(beg,end);
  }
  return 0;
}

void gfq ( SpiceDouble et, SpiceDouble *value ) {

  // max separation between all non-0 planets in planets
  // TODO: get min solar separation (not necessarily here)
  SpiceInt i,j;
  SpiceDouble sep, lt, max;
  SpiceDouble position[planetcount][3];
  // TODO: why do I need a temp var here?
  SpiceDouble temp[3];

  // compute the Earth positions first for efficiency
  for (i=1; i<=planetcount; i++) {
    spkezp_c(planets[i], et, "J2000", "LT+S", 399, temp, &lt);
    // copy from temp var (argh!)
    for (j=0; j<=2; j++) {position[i][j] = temp[j];}
  }

  // and now the angle diffs (keep only min)
  for (i=1; i<=planetcount; i++) {
    for (j=i+1; j<=planetcount; j++) {
      //      printf("I3: %d %f -> %f %f %f %f\n",planets[i],et2jd(et),position[i][0],position[i][1],position[i][2],position[i][3]);
      //      printf("I3: %d %f -> %f %f %f %f\n",planets[i],et2jd(et),test[0],test[1],test[2],test[3]);
      sep = vsep_c(position[i],position[j]);
      if (sep>max) {max=sep;}
    }
  }

  //  if (max<SIXDEGREES){printf("ABOUT TO RETURN: %f -> %f\n",et2jd(et),max);}
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


