#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 20000
#define TIMFMT "YYYY-MON-DD HR:MN:SC.###"
#define TIMLEN 41

// gfq = function that returns scalar value of interest
void gfq (SpiceDouble et, SpiceDouble * value );
// gfdecrx = function that determines whether gfq is decreasing
void gfdecrx (void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
		 SpiceDouble et, SpiceBoolean * isdecr );
 
doublereal dvnorm_(doublereal *state);

int main( int argc, char **argv ) {

 SPICEDOUBLE_CELL (result, 2*MAXWIN);
 SPICEDOUBLE_CELL (cnfine, 2);
 SpiceDouble step,adjust,refval,beg,end;
 SpiceChar begstr [ TIMLEN ];
 SpiceChar endstr [ TIMLEN ];
 SpiceInt count,i;
 furnsh_c( "standard.tm" );

 // 1970 to 2038 (all "Unix time")
 wninsd_c (-946684800., 2147483647.+946684800., &cnfine);
 
 gfuds_c (gfq, gfdecrx, "<", 0.10472, 0., 86400., MAXWIN, &cnfine, &result );

 count = wncard_c( &result );
 
 for ( i = 0; i < count; i++ ) {
 wnfetd_c ( &result, i, &beg, &end );
 timout_c ( beg, TIMFMT, TIMLEN, begstr );
 timout_c ( end, TIMFMT, TIMLEN, endstr );
 printf ( "Start time, drdt = %s \n", begstr );
 printf ( "Stop time, drdt = %s \n", endstr );
 }
 return( 0 );
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {

  // angular separation between Mars and Regulus
  SpiceDouble mars[3];
  SpiceDouble lt;

  // TODO: this shouldnt have to be here
  // TODO: not actually Regulus at the moment
  // position of Regulus
  SpiceDouble reg[3];
  radrec_c(1,10.1333395277778/12*pi_c(),11.9666722222222/180*pi_c(),reg);

  spkezp_c(4, et, "J2000", "NONE", 399, mars, &lt);
  *value = vsep_c(mars,reg);
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
