/*

 Attempts to answer http://astronomy.stackexchange.com/questions/19301/period-of-unique-horoscopes/19306#19306

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"


// the next two includes are part of the CSPICE library
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#define TIMLEN 41
#define TIMFMT "YYYY-MON-DD HR:MN:SC.###"

// TODO: add below to lib
int signum(double x) {
  // shouldnt compare double to zero, but ok here
  if (x==0) {return 0;}
  return x>0?1:-1;
}

// TODO: add below to lib
// wrapper around spkgeo_c that returns the XYZ and spherical
// coordinates, their derivatives, and whether these derivates are
// positive or negative

// TODO: check to see if spherical coords give lat or colat

SpiceDouble *geom_info(SpiceInt targ, SpiceDouble et, ConstSpiceChar *ref, 
		       SpiceInt obs) {

  static SpiceDouble results[18];
  SpiceDouble lt, jacobi[3][3];
  SpiceInt i;

  // the "output" from spkgeo_c() into the first 6 entries
  spkgeo_c(targ, et, ref, obs, results, &lt);

  // signum of the x y z dervs are entries 6-8
  for (i=6; i<=8; i++) {results[i] = signum(results[i-3]);}

  // the spherical of the coordinates are next 3 (9-11)
  recsph_c(results, &results[9], &results[10], &results[11]);

  // change in spherical coordinates (12-14)
  dsphdr_c(results[0], results[1], results[2], jacobi);
  mxv_c(jacobi, &results[3], &results[12]);

  // and the sign of that change
  for (i=15; i<=17; i++) {results[i] = signum(results[i-3]);}

  return results;
}

// returns the sine of the angular distance to the nearest cusp
// (multiple of n radians of longitude) for a given
// target/time/planet/refframe

// NOTE: using sine here so we can find bisecting points which are
// much easier than finding minima

SpiceDouble distance_to_cusp (SpiceDouble n, SpiceInt targ, SpiceDouble et,
			      ConstSpiceChar *ref, SpiceInt obs) {

  SpiceDouble *results = geom_info(targ, et, ref, obs);
  return sin(pi_c()/n*results[10]);
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {
  *value = distance_to_cusp(1, et);
}

void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  uddc_c(udfuns, et, 10, isdecr);
}

// gfdecrx = function that determines whether gfq is decreasing
// void gfdecrx (void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
//	      SpiceDouble et, SpiceBoolean * isdecr );

int main (int argc, char **argv) {

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  // TODO: this is just plain silly
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");

  SpiceInt i;
  SpiceDouble *array;
  array = geom_info(1, unix2et(0), "ECLIPDATE", 399);

  for (i=0; i<18; i++) {
    printf("result[%d] = %f\n", i, array[i]);
  }

  
  /*
  SPICEDOUBLE_CELL (result, 2*MAXWIN);
  SPICEDOUBLE_CELL (cnfine, 2);
  SpiceDouble step,adjust,refval,beg,end;
  SpiceChar begstr [ TIMLEN ];
  SpiceChar endstr [ TIMLEN ];
  SpiceInt count,i;

  // 1970 to 2038 (all "Unix time")
  wninsd_c (-946684800., 2147483647.+946684800., &cnfine);

  gfuds_c (gfq, gfdecrx, "LOCMIN", 0., 0., 1800., MAXWIN, &cnfine, &result);

  count = wncard_c( &result );
 
  for ( i = 0; i < count; i++ ) {
    wnfetd_c ( &result, i, &beg, &end );
    timout_c ( beg, TIMFMT, TIMLEN, begstr );
    timout_c ( end, TIMFMT, TIMLEN, endstr );
    printf ( "Start time, drdt = %s \n", begstr );
    printf ( "Stop time, drdt = %s \n", endstr );
  }
  return( 0 );

  */
}
