#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
// this the wrong way to do things
#include "/home/user/BCGIT/ASTRO/bclib.h"

#define MAXWIN 10000

int main(int argc, char **argv) {

  SpiceDouble t1, t2;

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  t1 = unix2et(1546300800);
  t2 = unix2et(1577836800);

  wninsd_c(t1, t2, &cnfine);

  gfoclt_c("ANY", "599", "ELLIPSOID", "IAU_JUPITER", "10", "ELLIPSOID", "IAU_SUN", "XCN", "501", 3600, &cnfine, &result);

  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end;

  for (int i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    printf("%f %f\n",et2unix(beg),et2unix(end));
  }
	    	    
}

/*

values for Jupiter blocking Sun as viewed from Io

gfoclt_c ( "ANY", 599, "ELLIPSOID", "IAU_JUPITER", 10,
 "ELLIPSOID", "IAU_SUN", "XCN", 501, 1, 


cnfine window for input time limit it 2019


result = result window


*/



/*
   void gfoclt_c ( ConstSpiceChar   * occtyp,
                   ConstSpiceChar   * front,
                   ConstSpiceChar   * fshape,
                   ConstSpiceChar   * fframe,
                   ConstSpiceChar   * back,
                   ConstSpiceChar   * bshape,
                   ConstSpiceChar   * bframe,
                   ConstSpiceChar   * abcorr,
                   ConstSpiceChar   * obsrvr,
                   SpiceDouble        step,
                   SpiceCell        * cnfine,
                   SpiceCell        * result )

*/

