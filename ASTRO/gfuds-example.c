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
   
  str2et_c( "2007 JAN 01", &begtim );
  str2et_c( "2007 APR 01", &endtim );
  wninsd_c ( begtim, endtim, &cnfine );
   
  step   = spd_c();
  adjust = 0.;
  refval = .3365;
   
    gfuds_c ( gfq, gfdecrx, "<", refval, adjust, step,
	      MAXWIN, &cnfine, &result );

    count = wncard_c( &result );
   
    if (count == 0 )
      {
	printf ( "Result window is empty.\n\n" );
      } else {
      for ( i = 0;  i < count;  i++ )
	{
   
	  wnfetd_c ( &result, i, &beg, &end );
	  
	  timout_c ( beg, TIMFMT, TIMLEN, begstr );
	  timout_c ( end, TIMFMT, TIMLEN, endstr );
	  
	  printf ( "Start time, drdt = %s \n", begstr );
	  printf ( "Stop time,  drdt = %s \n", endstr );
	  
	}
      
    }
   
    printf("\n");
   
  kclear_c();
  return( 0 );
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {
   
         /* Initialization */
  SpiceInt             targ   = 301;
  SpiceInt             obs    = 10;
  
  SpiceChar          * ref    = "J2000";
  SpiceChar          * abcorr = "NONE";
   
  SpiceDouble          state [6];
  SpiceDouble          lt;
   
  
  spkez_c ( targ, et, ref, abcorr, obs, state, &lt );
   
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
