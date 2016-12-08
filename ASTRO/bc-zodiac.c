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
#define MAXWIN 5000000
#define TIMLEN 41
#define TIMFMT "YYYY##-MON-DD HR:MN"

// global variables

SpiceInt gplanet = 0;

// the planet ids we are interested in

const int iplanets[] = {1, 2, 301, 4, 5, 6, 10};

const char *houses[] = {"ARIES", "TAURUS", "GEMINI", "CANCER", "LEO", "VIRGO",
			"LIBRA", "SCORPIO", "SAGITTARIUS", "CAPRICORN",
			"AQUARIUS", "PISCES"};

// planets[0] is the barycenter, never used
const char *planets[] = {"SSB", "MERCURY", "VENUS", "EARTH", "MARS", "JUPITER",
			 "SATURN", "URANUS", "NEPTUNE", "PLUTO", "SUN"};

// convert house to string, optionally in terse format
char *house2str(int house, char *type) {

  // in case we need to return a string
  static char res[200];

  if (strcmp(type, "TERSE") == 0) {

    if (house<=9) {
      sprintf(res, "%d", house);
      return res;
    }

    if (house==10) {return "A";}
    if (house==11) {return "B";}
  }

  return houses[house];
}

// convert planet to string, optionally in terse format
char *planet2str(int planet, char *type) {

  // in case we need to return a string
  static char res[200];

  if (strcmp(type, "TERSE") == 0) {

    if (planet<=9) {
      sprintf(res, "%d", planet);
      return res;
    }

    if (planet==301) {return "M";}
    if (planet==10) {return "S";}
    return "?";
  }

  if (planet<=10) {return planets[planet];}
  if (planet == 301) {return "MOON";}
  return "?";
}

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

// TODO: replace 1 with gplanet, global planet definition
void gfq ( SpiceDouble et, SpiceDouble * value ) {
  *value = distance_to_cusp(pi_c()/6, gplanet, et, "ECLIPDATE", 399);
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
  // various formats
  SpiceChar begstr[TIMLEN], classic[100], terse[100];
  SpiceDouble beg,end;
  SpiceInt count,i,j,house;
  SpiceDouble *array;

  // kernels we need incl ECLIPDATE
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  // TODO: this is just plain silly
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/000157.html");

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);
  
  // close to the entire range for DE431
  wninsd_c(-479695089600.+86400*468, 479386728000., &cnfine);

  // testing really old and new for formatting/etc
  //  wninsd_c(-479695089600.+86400*468, -479695089600.+86400*500, &cnfine);
  // wninsd_c(479386728000-86400*468, 479386728000, &cnfine);

  // TODO: figure out how to compute sizeof(iplanets) properly, this is hack
  for (j=0; j<sizeof(iplanets)/4; j++) {

    gplanet = iplanets[j];
    array = geom_info(gplanet, -479695089600.+86400*468, "ECLIPDATE", 399);
    house = floor(array[11]*dpr_c()/30);
    house = (house+12)%12;
    // figure out ecliptic coordinates at earliest time
    printf("SEPOCH: %s %s %f\n",planet2str(iplanets[j], ""),house2str(house, ""), array[11]*dpr_c());

    // found error, testing
    //    array = geom_info(gplanet, unix2et(-478707368069.509216), "ECLIPDATE", 399);
    //    printf("FIXED: %s %s %f\n",planet2str(iplanets[j], ""),house2str(house, ""), array[11]*dpr_c());


    // TODO: this continue appears because I did this later
    continue;

    gfuds_c (gfq, gfdecrx, "=", 0., 0., 86400., MAXWIN, &cnfine, &result);
    count = wncard_c(&result);
    
    for (i=0; i<count; i++) {

      // find the time of event (beg == end in this case)
      wnfetd_c (&result, i, &beg, &end);

      // find ecliptic longitude (and if its increasing/decreasing)
      array = geom_info(gplanet, beg, "ECLIPDATE", 399);

      // pretty print the time
      timout_c (beg, TIMFMT, TIMLEN, begstr);

      house = rint(array[11]*dpr_c()/30);
      if (array[17] < 0) {house--;}
      house = (house+12)%12;

      // the classic form
      // we still include unix minute for sorting
      sprintf(classic, "%s %s ENTERS %s %s",  begstr,  
	      planet2str(gplanet, ""), houses[house], 
	      array[17]<0?"RETROGRADE":"PROGRADE");

      sprintf(terse, "%f %s%s%s", et2unix(beg), 
	      planet2str(gplanet, "TERSE"), house2str(house, "TERSE"),
	      array[17]<0?"-":"");

      printf("%s %s\n", classic, terse);
    }
  }
  return( 0 );
}

/*

array: 0 = aries

*/
 
