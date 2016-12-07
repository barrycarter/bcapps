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
#define TIMFMT "YYYY-MON-DD HR:MN"

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

  // TODO: details spherical coords order a bit better

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

  //  for (i=0; i<=17; i++) {
  //    printf("RESULTS[%d] (%f): %f\n", i, et, results[i]);
  //  }

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
  return sin(pi_c()/n*results[11]);
}

void gfq ( SpiceDouble et, SpiceDouble * value ) {
  *value = distance_to_cusp(pi_c()/6, 1, et, "ECLIPDATE", 399);
}

void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  uddc_c(udfuns, et, 10, isdecr);
}

// gfdecrx = function that determines whether gfq is decreasing
// void gfdecrx (void (*udfuns) (SpiceDouble et, SpiceDouble *value ),
//	      SpiceDouble et, SpiceBoolean * isdecr );

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL (result, 2*MAXWIN);
  SPICEDOUBLE_CELL (cnfine, 2);
  SpiceChar begstr[TIMLEN], endstr[TIMLEN];
  SpiceDouble step,adjust,refval,beg,end;
  SpiceInt count,i;
  SpiceDouble *array;

  // kernels we need incl ECLIPDATE
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  // TODO: this is just plain silly
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");
  
  // test for one year
  wninsd_c (year2et(2017), year2et(2018), &cnfine);

  gfuds_c (gfq, gfdecrx, "=", 0., 0., 86400., MAXWIN, &cnfine, &result);

  count = wncard_c(&result);
 
  for (i=0; i<count; i++) {

    // find the time of event (beg == end in this case)
    wnfetd_c (&result, i, &beg, &end);

    // find mercury's ecliptic longitude (and if its increasing/decreasing)
    array = geom_info(1, beg, "ECLIPDATE", 399);

    // pretty print the time
    timout_c (beg, TIMFMT, TIMLEN, begstr);

    int house = rint(array[11]*dpr_c()/30);
    if (array[17] < 0) {house--;}
    house = (house+12)%12;

    printf("AT: %s, LONG: %f (%d), DIR: %f\n", begstr, array[11]*dpr_c()/30,
	   house, array[17]);

  }
  return( 0 );
}

/*

array: 0 = aries

*/
 
