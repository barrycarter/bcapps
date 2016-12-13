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
#define TIMFMT "ERAYYYY##-MON-DD HR:MN:SC ::MCAL ::RND"
#define FRAME "ECLIPDATE"

// global variables

SpiceInt gplanet = 0;

// the planet ids we are interested in (actually, barycenters)

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

  return (char *) houses[house];
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

  if (planet<=10) {return (char *) planets[planet];}
  if (planet == 301) {return "MOON";}
  return "?";
}

// returns the sine of the angular distance to the nearest cusp
// (multiple of n radians of longitude) for a given
// target/time/planet/refframe

// NOTE: using sine here so we can find bisecting points which are
// much easier than finding minima

// TODO: abs value would be much faster?

SpiceDouble distance_to_cusp (SpiceDouble n, SpiceInt targ, SpiceDouble et,
			      ConstSpiceChar *ref, SpiceInt obs) {
  SpiceDouble *results = geom_info(targ, et, ref, obs);
  return sin(pi_c()/n*results[11]);
}

void gfq ( SpiceDouble et, SpiceDouble *value ) {
  *value = distance_to_cusp(pi_c()/6, gplanet, et, FRAME, 399);
}

void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  uddc_c(udfuns, et, 10, isdecr);
}

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL (result, 2*MAXWIN);
  SPICEDOUBLE_CELL (cnfine, 2);
  SPICEDOUBLE_CELL (range, 2);
  // various formats
  SpiceChar begstr[TIMLEN], classic[100], terse[100];
  // nut for testing only
  SpiceDouble beg,end,stime,etime, nut[4];
  SpiceInt count,i,j,house;
  SpiceDouble *array;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);
  
  // find coverage (junk uses of beg and end below)
  // we use the start of part 1 and the end of part 2
  spkcov_c("/home/barrycarter/SPICE/KERNELS/de431_part-1.bsp", 399, &range);
  wnfetd_c (&range, 0, &stime, &end);
  spkcov_c("/home/barrycarter/SPICE/KERNELS/de431_part-2.bsp", 399, &range);
  wnfetd_c(&range, 0, &beg, &etime);
  
  // any integers below 4042 and 12 below fail for at least one planet
  //  wninsd_c(stime+4042,etime-12, &cnfine);

  // for testing
  wninsd_c(year2et(5000), year2et(5001), &cnfine);

  // TODO: figure out how to compute sizeof(iplanets) properly, this is hack
  for (j=0; j<sizeof(iplanets)/4; j++) {

    gplanet = iplanets[j];

    gfuds_c (gfq, gfdecrx, "=", 0., 0., 86400., MAXWIN, &cnfine, &result);
    count = wncard_c(&result);
    
    for (i=0; i<count; i++) {

      // find the time of event (beg == end in this case)
      wnfetd_c (&result, i, &beg, &end);

      // the nutation of the ecliptic just in case this fixes things
      // the first number we already ue
      //      zzwahr_(&beg, nut);
      //      printf("NUT: %f %f %f %f\n", nut[0]*dpr_c(), nut[1]*dpr_c(), nut[2]*dpr_c(), nut[3]*dpr_c());

      // find ecliptic longitude (and if its increasing/decreasing)
      array = geom_info(gplanet, beg, FRAME, 399);

      // pretty print the time
      timout_c (beg, TIMFMT, TIMLEN, begstr);

      house = rint(array[11]*dpr_c()/30);
      if (array[17] < 0) {house--;}
      house = (house+12)%12;

      // the classic form
      sprintf(classic, "%s %s ENTERS %s %s",  begstr,  
	      planet2str(gplanet, ""), houses[house], 
	      array[17]<0?"RETROGRADE":"PROGRADE");

      sprintf(terse, "%lld %s%s%s", (long long) floor(beg+0.5), 
	      planet2str(gplanet, "TERSE"), house2str(house, "TERSE"),
	      array[17]<0?"-":"+");

      printf("%s %s\n", classic, terse);
    }
  }
  return(0);
}
