/* This is a major modification of example(1) in
   http://emfisis.physics.uiowa.edu/Software/C/cspice/doc/html/cspice/gfsep_c.html to find when any two given planets are less than 6 degrees apart */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"

#define MAXWIN 100000

int main( int argc, char **argv )
{

  SPICEDOUBLE_CELL(result,2*MAXWIN );
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(cnfiner,2);
  SpiceInt i;
  SpiceDouble j;

  // which ephermis's to use
  furnsh_c( "/home/barrycarter/BCGIT/ASTRO/standard.tm" );

  // TOL too small otherwise; this is one second
  gfstol_c(1.);

  // SPICE window for all DE431
  // wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // FOR TESTING PURPOSES ONLY!!!!
  wninsd_c (946684800., 2147483648., &cnfine);
    
  // I send these as: observer b1 b2, thus the odd argv order below
  // 0.10471975511965977462 radians = 6 degrees

  gfsep_c(argv[2],"POINT","J2000",argv[3],"POINT","J2000","NONE",argv[1],
	  "<", 0.10471975511965977462,0,86400.,MAXWIN,&cnfine,&result);

  SpiceInt count = wncard_c(&result);
  SpiceDouble begtim, endtim, mintim;

  for (i=0; i<count; i++) {
    wnfetd_c ( &result,i,&begtim,&endtim);
    printf("%s %s %s 6deg %f %f\n",argv[1],argv[2],argv[3],begtim,endtim);

    // also find min separation in this interval
    // TODO: use of ABSMIN below may miss some "conjunctions"
    //    gfsep_c(argv[2],"POINT","J2000",argv[3],"POINT","J2000","NONE",argv[1],
    //  "ABSMIN", 0,0,86400.,MAXWIN,&cnfiner,&result);
  }
}

