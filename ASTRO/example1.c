#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SpiceUsr.h"

#define       MAXWIN    1000
#define       TIMFMT    "YYYY-MON-DD HR:MN:SC.###### (TDB) ::TDB ::RND"
#define       TIMLEN   41

int main( int argc, char **argv )
{

  SPICEDOUBLE_CELL ( result, 2*MAXWIN );
  SPICEDOUBLE_CELL ( cnfine, 2       );

  SpiceDouble begtim, endtim, step, adjust, refval, beg, end;

  SpiceChar         begstr [ TIMLEN ];
  SpiceChar         endstr [ TIMLEN ];

  SpiceChar       * targ1  = "MOON";
  SpiceChar       * frame1 = "NULL";
  SpiceChar       * shape1 = "SPHERE";

  SpiceChar       * targ2  = "EARTH";
  SpiceChar       * frame2 = "NULL";
  SpiceChar       * shape2 = "SPHERE";

  SpiceChar       * abcorr = "NONE";
  SpiceChar       * relate = "LOCMAX";

  SpiceChar       * obsrvr = "SUN";

  SpiceInt          count;
  SpiceInt          i;


  furnsh_c( "standard.tm" );
    
  str2et_c( "2007 JAN 01", &begtim );
  str2et_c( "2008 JAN 01", &endtim );

  wninsd_c ( begtim, endtim, &cnfine );

  step   = 6.*spd_c();
  adjust = 0.;
  refval = 0.;

  gfsep_c ( targ1, shape1, frame1, targ2, shape2, frame2, abcorr, obsrvr,
	    relate, refval, adjust, step, MAXWIN, &cnfine, &result);
  count = wncard_c( &result );

    if (count == 0 )
      {
        printf ( "Result window is empty.\n\n" );
      }
    else
      {
        for ( i = 0;  i < count;  i++ )
   {

   wnfetd_c ( &result, i, &beg, &end );

               timout_c ( beg, TIMFMT, TIMLEN, begstr );
               timout_c ( end, TIMFMT, TIMLEN, endstr );

               printf ( "Interval %d\n", i + 1);
               printf ( "Beginning TDB %s \n", begstr );
               printf ( "Ending TDB    %s \n", endstr );

   }
      }

         kclear_c();
         return( 0 );
}
