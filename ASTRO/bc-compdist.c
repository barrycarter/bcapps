#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "/home/user/BCGIT/ASTRO/bclib.h"
#define MAXWIN 200000
#define TIMFMT "YYYY-MON-DD HR:MN:SC.###"
#define TIMLEN 41


void gfq ( SpiceDouble et, SpiceDouble *value ) {

  SpiceDouble sun[6], mars[6], ltsun, ltmars;

  spkezr_c("Sun", et, "J2000", "CN+S", "Earth", sun, &ltsun);
  spkezr_c("4", et, "J2000", "CN+S", "Earth", mars, &ltmars);

  // positive means that mars is further

  *value = vnorm_c(mars) - vnorm_c(sun);
}
 
int main( int argc, char **argv ) {

 SPICEDOUBLE_CELL (result, 2*MAXWIN);
 SPICEDOUBLE_CELL (cnfine, 2);
 SpiceDouble beg, end, aft, bef;
 SpiceInt count,i;
 furnsh_c( "standard.tm" );


 wninsd_c (-500*365.2425*86400, 500*365.2425*86400, &cnfine);

 // TEST
 // wninsd_c (0, 86400*365.2425*60, &cnfine);

 //  for (i = 0; i < 1000; i++) {gfq(i*86400, &step);}

 gfuds_c(gfq, isDecreasing, "=", 0, 0, 86400, MAXWIN, &cnfine, &result);

 count = wncard_c( &result );
 
 for ( i = 0; i < count; i++ ) {
   wnfetd_c ( &result, i, &beg, &end );
   gfq(beg+1, &aft);
   gfq(beg-1, &bef);
   printf ( "%f %f\n", beg, aft-bef);
 }
 return( 0 );
}
