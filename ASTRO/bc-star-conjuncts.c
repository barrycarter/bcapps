#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#define SIXDEGREES 0.10471975511965977462

// Usage: $0 naif-id-of-planet ra-of-star-in-radians dec-of-star-in-radians

// actually declaring entire functions here, not just prototype
double et2jd(double d) {return 2451544.5+d/86400.;}
double unix2et(double d) {return d-946684800.;}

// gfq = function that returns scalar value of interest
void gfq (SpiceDouble et, SpiceDouble * value );
// gfdecrx = function that determines whether gfq is decreasing
void gfdecrx (void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
		 SpiceDouble et, SpiceBoolean * isdecr );
 
int main( int argc, char **argv ) {

  // TODO: this is ugly and probably wrong
  setenv("PLANET",argv[1],1);
  setenv("RA",argv[2],1);
  setenv("DEC",argv[3],1);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  // argv[4] is the optional star name
  printf("PLANET: %s, RA: %s DEC: %s (%s)\n\n",argv[1],argv[2],argv[3],argv[4]);

  SPICEDOUBLE_CELL (result, 2*MAXWIN);
  SPICEDOUBLE_CELL (cnfine, 2);
  SpiceDouble beg,end;
  SpiceInt count,i;
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // DE431 limits
  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1970 to 2038 (all "Unix time")
  //  wninsd_c (unix2et(0),unix2et(2147483647),&cnfine);
 
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

  // angular separation between planet and star
  SpiceDouble planet[3];
  SpiceDouble lt;
  SpiceDouble star[3];

  // TODO: this shouldnt have to be here
  radrec_c(1,atof(getenv("RA")),atof(getenv("DEC")),star);
  spkezp_c(atoi(getenv("PLANET")), et, "J2000", "NONE", 399, planet, &lt);
  *value = vsep_c(planet,star);
  return;
}
 
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
	      SpiceDouble et, SpiceBoolean * isdecr ) {
 SpiceDouble dt = 10.;
 uddc_c( udfuns, et, dt, isdecr );
 return;
}

