#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define       MAXWIN    20000
#define       TIMFMT    "YYYY-MON-DD HR:MN:SC.###"
#define       TIMLEN    41
#define       NLOOPS    7
   
void    gfq     ( SpiceDouble et, SpiceDouble * value );
void    gfdecrx ( void ( * udfuns ) ( SpiceDouble    et,
				      SpiceDouble  * value ),
		  SpiceDouble    et,
		  SpiceBoolean * isdecr );
   
doublereal dvnorm_(doublereal *state);
   
   
int main( int argc, char **argv ) {

  SPICEDOUBLE_CELL ( result, 2*MAXWIN );
  SPICEDOUBLE_CELL ( cnfine, 2        );
   
  SpiceDouble       begtim,endtim,step,adjust,refval,beg,end;
  SpiceChar         begstr [ TIMLEN ];
  SpiceChar         endstr [ TIMLEN ];
  SpiceInt          count,i,j;
  
  furnsh_c( "standard.tm" );

  // 1970 to 2038 (all "Unix time")
  wninsd_c (-946684800., 2147483647.+946684800., &cnfine);
   
  step   = spd_c();
  adjust = 0.;
  refval = .3365;
   
  gfuds_c (gfq, gfdecrx, "<", refval, adjust, step, MAXWIN, &cnfine, &result );

  count = wncard_c( &result );
   
  for ( i = 0;  i < count;  i++ ) {
    wnfetd_c ( &result, i, &beg, &end );
    timout_c ( beg, TIMFMT, TIMLEN, begstr );
    timout_c ( end, TIMFMT, TIMLEN, endstr );
    printf ( "Start time, drdt = %s \n", begstr );
    printf ( "Stop time,  drdt = %s \n", endstr );
  }
  kclear_c();
  return( 0 );
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {
   
  SpiceDouble          state [6];
  SpiceDouble          lt;
  
  spkez_c (301, et, "J2000", "NONE", 10, state, &lt );
  *value = dvnorm_( state );
  return;
}
   
void gfdecrx ( void ( * udfuns ) ( SpiceDouble    et,
				   SpiceDouble  * value ),
	       SpiceDouble    et,
	       SpiceBoolean * isdecr ) {
   
  SpiceDouble         dt = 10.;
  uddc_c( udfuns, et, dt, isdecr );
  return;
}
