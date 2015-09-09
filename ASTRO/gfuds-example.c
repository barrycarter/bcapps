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
   
   
int main( int argc, char **argv )
{
   
         /.
  Create the needed windows. Note, one interval
    consists of two values, so the total number
         of cell values to allocate is twice
         the number of intervals.
         ./
    SPICEDOUBLE_CELL ( result, 2*MAXWIN );
  SPICEDOUBLE_CELL ( cnfine, 2        );
   
  SpiceDouble       begtim;
  SpiceDouble       endtim;
  SpiceDouble       step;
  SpiceDouble       adjust;
  SpiceDouble       refval;
  SpiceDouble       beg;
  SpiceDouble       end;
   
  SpiceChar         begstr [ TIMLEN ];
  SpiceChar         endstr [ TIMLEN ];
   
  SpiceInt          count;
  SpiceInt          i;
  SpiceInt          j;
   
  ConstSpiceChar * relate [NLOOPS] = { "=",
				       "<",
				       ">",
				       "LOCMIN",
				       "ABSMIN",
				       "LOCMAX",
                                              "ABSMAX"
  };
   
  printf( "Compile date %s, %s\n\n", __DATE__, __TIME__ );
   
         /.
         Load kernels.
         ./
	   furnsh_c( "standard.tm" );
   
         /.
         Store the time bounds of our search interval in the `cnfine'
         confinement window.
         ./
         str2et_c( "2007 JAN 01", &begtim );
         str2et_c( "2007 APR 01", &endtim );
   
         wninsd_c ( begtim, endtim, &cnfine );
   
         /.
         Search using a step size of 1 day (in units of seconds). The reference
         value is .3365 km/s. We're not using the adjustment feature, so
         we set `adjust' to zero.
         ./
         step   = spd_c();
         adjust = 0.;
         refval = .3365;
   
         for ( j = 0;  j < NLOOPS;  j++ )
            {
   
            printf ( "Relation condition: %s \n",  relate[j] );
   
            /.
            Perform the search. The SPICE window `result' contains
            the set of times when the condition is met.
            ./
   
	   gfuds_c ( gfq,
		     gfdecrx,
		     relate[j],
		     refval,
		     adjust,
		     step,
		     MAXWIN,
		     &cnfine,
		     &result );
   
	 count = wncard_c( &result );
   
            /.
            Display the results.
            ./
	      if (count == 0 )
		{
		  printf ( "Result window is empty.\n\n" );
		}
	      else
		{
		  for ( i = 0;  i < count;  i++ )
		    {
   
                  /.
                  Fetch the endpoints of the Ith interval
                  of the result window.
                  ./
		    wnfetd_c ( &result, i, &beg, &end );
   
                  timout_c ( beg, TIMFMT, TIMLEN, begstr );
                  timout_c ( end, TIMFMT, TIMLEN, endstr );
   
                  printf ( "Start time, drdt = %s \n", begstr );
                  printf ( "Stop time,  drdt = %s \n", endstr );
   
		    }
   
		}
   
            printf("\n");
   
}
   
kclear_c();
return( 0 );
}
   
   
   
      /.
      The user defined functions required by GFUDS.
   
         gfq     for udfuns
         gfdecrx for udqdec
      ./
   
   
   
      /.
      -Procedure Procedure gfq
      ./
   
      void gfq ( SpiceDouble et, SpiceDouble * value )
   
      /.
      -Abstract
   
      User defined geometric quantity function. In this case,
         the range rate from the sun to the Moon at TDB time `et'.
   
      ./
         {
   
         /. Initialization ./
         SpiceInt             targ   = 301;
         SpiceInt             obs    = 10;
   
         SpiceChar          * ref    = "J2000";
         SpiceChar          * abcorr = "NONE";
   
         SpiceDouble          state [6];
         SpiceDouble          lt;
   
         /.
         Retrieve the vector from the Sun to the Moon in the J2000
         frame, without aberration correction.
         ./
         spkez_c ( targ, et, ref, abcorr, obs, state, &lt );
   
         /.
         Calculate the scalar range rate corresponding the
        `state' vector.
         ./
   
	  *value = dvnorm_( state );
   
return;
}
   
   
   
      /.
      -Procedure gfdecrx
      ./
   
      void gfdecrx ( void ( * udfuns ) ( SpiceDouble    et,
                                         SpiceDouble  * value ),
                     SpiceDouble    et,
                     SpiceBoolean * isdecr )
   
      /.
      -Abstract
   
         User defined function to detect if the function derivative
         is negative (the function is decreasing) at TDB time `et'.
      ./
         {
   
         SpiceDouble         dt = 10.;
   
         /.
         Determine if "udfuns" is decreasing at `et'.
   
         uddc_c   - the GF function to determine if
                    the derivative of the user defined
                    function is negative at `et'.
   
         uddf_c   - the SPICE function to numerically calculate the
                    derivative of "udfuns" at `et' for the
                    interval [et-dt, et+dt].
         ./
   
		    uddc_c( udfuns, et, dt, isdecr );
   
return;
}
