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

  // fill the static planets array
  SpiceInt i;
  for (i=1; i<argc; i++) {planets[i] = atoi(argv[i]);}
  planetcount = argc-1;

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  SPICEDOUBLE_CELL (result, 2*MAXWIN);
  SPICEDOUBLE_CELL (cnfine, 2);
  SpiceDouble beg,end;
  SpiceInt count;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // DE431 limits
  //  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1970 to 2038 (all "Unix time") for testing
  //  wninsd_c (unix2et(0),unix2et(2147483647),&cnfine);

  // even shorter testing
  wninsd_c (0,86400*365.,&cnfine);
 
  gfuds_c (gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result );

  count = wncard_c( &result );

  for (i=0; i<count; i++) {
    wnfetd_c ( &result, i, &beg, &end );

    // this is cheating, but I'm not using &end, so...
    gfq(beg,&end);

    // ignore more than 6 degrees
    if (end>SIXDEGREES) {continue;}

    printf ("%f %f\n",et2jd(beg),end/pi_c()*180.);
  }
  return( 0 );
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {

  // max separation between all non-0 planets in planets
  // TODO: get min solar separation (not necessarily here)
  SpiceInt i,j;
  SpiceDouble sep, maxsep, lt;
  SpiceDouble position[planetcount][2];

  // compute the Earth positions first for efficiency
  for (i=1; i<=planetcount; i++) {
    spkezp_c(planets[i], et, "J2000", "LT+S", 399, position[i], &lt);
  }

  // separation can never be more than pi, so this works
  maxsep = 4.;

  // and now the angle diffs (keep only min)
  for (i=1; i<=planetcount; i++) {
    for (j=i+1; j<=planetcount; j++) {
      sep = vsep_c(position[i],position[j]);
      printf("SEP: %d %d %f\n",planets[i],planets[j],sep);
    }
  }


  value=0;
  return;
}
 
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
	      SpiceDouble et, SpiceBoolean * isdecr ) {
 SpiceDouble dt = 10.;
 uddc_c( udfuns, et, dt, isdecr );
 return;
}

