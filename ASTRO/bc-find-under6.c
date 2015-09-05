/* This is a major modification of example(1) in
   http://emfisis.physics.uiowa.edu/Software/C/cspice/doc/html/cspice/gfsep_c.html to find when any two given planets are less than 6 degrees apart */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"

#define       MAXWIN    1000
#define       TIMFMT    "YYYY-MON-DD HR:MN:SC.###### (TDB) ::TDB ::RND"
#define       TIMLEN   41

int main( int argc, char **argv )
{

  SPICEDOUBLE_CELL(result,2*MAXWIN );
  SPICEDOUBLE_CELL(cnfine,2);
  int i;

  // which ephermis's to use
  furnsh_c( "/home/barrycarter/BCGIT/ASTRO/standard.tm" );

  // SPICE window for all DE431
  //  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine );

  // SPICE window testing
  wninsd_c (0, 86400.*365.2425*500, &cnfine );
    
  // I sent these as: observer b1 b2, thus the odd argv order below
  // 0.10471975511965977462 radians = 6 degrees
  gfsep_c(argv[2],"POINT","J2000",argv[3],"POINT","J2000","NONE",argv[1],
	  "<", 0.10471975511965977462,0,1.*spd_c(),10000,&cnfine,&result);

  SpiceInt count = wncard_c( &result );

  SpiceDouble begtim, endtim;

  for (i=0; i<count; i++) {
    wnfetd_c ( &result,i,&begtim,&endtim);
    printf("%f,%f\n",begtim,endtim);

  }
}
