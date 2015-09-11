#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 20000
#define TIMFMT "YYYY-MON-DD HR:MN:SC.###"
#define TIMLEN 41

// Usage: $0 naif-id-of-planet ra-of-star-in-radians dec-of-star-in-radians

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

  printf("PLANET: %s, RA: %s DEC: %s\n",argv[1],argv[2],argv[3]);

  SPICEDOUBLE_CELL (result, 2*MAXWIN);
  SPICEDOUBLE_CELL (cnfine, 2);
  SpiceDouble step,adjust,refval,beg,end;
  SpiceChar begstr [ TIMLEN ];
  SpiceChar endstr [ TIMLEN ];
  SpiceInt count,i;
  furnsh_c("standard.tm");

 // 1970 to 2038 (all "Unix time")
 wninsd_c (-946684800., 2147483647.-946684800., &cnfine);
 
 gfuds_c (gfq, gfdecrx, "LOCMIN", 0.10472, 0., 86400., MAXWIN, &cnfine, &result );

 count = wncard_c( &result );
 
 for ( i = 0; i < count; i++ ) {
 wnfetd_c ( &result, i, &beg, &end );
 timout_c ( beg, TIMFMT, TIMLEN, begstr );
 timout_c ( end, TIMFMT, TIMLEN, endstr );
 printf ("%f - %f\n",beg,end-beg);
 }
 return( 0 );
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {

  // angular separation between Mars and Regulus
  SpiceDouble planet[3];
  SpiceDouble lt;
  SpiceDouble star[3];

  // TODO: this shouldnt have to be here
  radrec_c(1,atof(getenv("RA")),atof(getenv("DEC")),star);
  spkezp_c(atoi(getenv("PLANET")), et, "J2000", "NONE", 399, planet, &lt);
  *value = vsep_c(planet,star);
  return;
}
 
void gfdecrx ( void ( * udfuns ) ( SpiceDouble et,
				 SpiceDouble * value ),
	 SpiceDouble et,
	 SpiceBoolean * isdecr ) {
 
 SpiceDouble dt = 10.;
 uddc_c( udfuns, et, dt, isdecr );
 return;
}
