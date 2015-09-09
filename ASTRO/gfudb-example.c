      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>

      #include "SpiceUsr.h"
      #include "SpiceZfc.h"
      #include "SpiceZad.h"


      #define       MAXWIN    20000
      #define       TIMFMT    "YYYY-MON-DD HR:MN:SC.###"
      #define       TIMLEN    41
      #define       NLOOPS    7

void gfq ( void ( * udfunc ) ( SpiceDouble    et,
			       SpiceDouble  * value ),
	   SpiceDouble et,
	   SpiceBoolean * xbool );

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
  SpiceDouble       left;
  SpiceDouble       right;
  SpiceDouble       step;
  SpiceDouble       ltime;
  SpiceDouble       state  [6];

  SpiceChar         begstr [ TIMLEN ];
  SpiceChar         endstr [ TIMLEN ];

  SpiceInt          count;
  SpiceInt          i;

  printf( "Compile date %s, %s\n\n", __DATE__, __TIME__ );

         /.
         Load kernels.
         ./
	   furnsh_c( "standard.tm" );

         /.
         Store the time bounds of our search interval in the 'cnfine'
         confinement window.
         ./
	   str2et_c ( "Jan 1 2011", &begtim );
         str2et_c ( "Jan 1 2012", &endtim );

         wninsd_c ( begtim, endtim, &cnfine );


         /.
         The moon orbit about the earth-moon barycenter is
         twenty-eight days. The event condition occurs
	   during (very) approximately a quarter of the orbit. Use
         a step of five days.
         ./

	   step = 5.0 * spd_c();

         gfudb_c ( udf_c,
                   gfq,
                   step,
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
		 wnfetd_c ( &result, i, &left, &right );

               printf ( "Interval %ld\n", i );

               timout_c ( left, TIMFMT, TIMLEN, begstr );
               printf   ( "   Interval start: %s \n", begstr );
               spkez_c  ( 301, left, "IAU_EARTH", "NONE", 399, state, &ltime);
               printf   ( "                Z= %.12g \n", state[2] );
               printf   ( "               Vz= %.12g \n", state[5] );

               timout_c ( right, TIMFMT, TIMLEN, endstr );
               printf   ( "   Interval end  : %s \n", endstr );
               spkez_c  ( 301, right, "IAU_EARTH", "NONE", 399, state, &ltime);
               printf   ( "                Z= %.12g \n",   state[2] );
               printf   ( "               Vz= %.12g \n\n", state[5] );
		 }

	     }

         kclear_c();
         return( 0 );
}



      /.
      The user defined functions required by gfudb_c.

         udf_c   for udfuns
         gfq     for udfunb
      ./



      /.
      -Procedure Procedure gfq
      ./

      void gfq ( void ( * udfuns ) ( SpiceDouble    et,
                                     SpiceDouble  * value ),
                 SpiceDouble et,
                 SpiceBoolean * xbool )

      /.
      -Abstract

      User defined geometric boolean function:

           Z >= 0 with dZ/dt > 0.

      ./
{

         /.
         Initialization. Retrieve the vector from the earth to
	   the moon in the IAU_EARTH frame, without aberration
         correction.
         ./
	   SpiceInt             targ   = 301;
         SpiceInt             obs    = 399;

         SpiceChar          * ref    = "IAU_EARTH";
         SpiceChar          * abcorr = "NONE";

         SpiceDouble          state [6];
         SpiceDouble          lt;

         /.
         Evaluate the state of TARG from OBS at ET with
         correction ABCORR.
         ./
	   spkez_c ( targ, et, ref, abcorr, obs, state, &lt );

         /.
         Calculate the boolean value.
         ./

	   *xbool = (state[2] >= 0.0) && (state[5] > 0.0);

         return;
}
