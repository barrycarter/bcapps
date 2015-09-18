// find barycentric periapses and apoapses(?) for planet with the
// secondary goal of templating use of SPICE libraries

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/helpers.c"
#define MAXSEP 0.10471975511965977462
#define MAXWIN 1000000

// these are "globally" scoped
SpiceInt planets[7], planetcount;

// function to minimize is at top, one of only two things to change
void gfq (SpiceDouble et, SpiceDouble *value) {
  *value = earthmaxangle(et,planetcount,planets);
}

// this just takes differentials of gfq
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  SpiceDouble dt = 10.;
  uddc_c( udfuns, et, dt, isdecr );
  return;
}

// find and print (icky) min seps in given interval

void findmins (SpiceDouble beg, SpiceDouble end) {

  SpiceInt i, count;

  // SPICEDOUBLE_CELLs are static, so must reinit them each time, sigh
  SPICEDOUBLE_CELL(result, 200);
  SPICEDOUBLE_CELL(cnfine,2);
  scard_c(0,&result);
  scard_c(0,&cnfine);

  // create interval
  wninsd_c(beg,end,&cnfine);

  // get results
  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);

  count = wncard_c(&result); 

  for (i=0; i<count; i++) {
    wnfetd_c(&result,i,&beg,&end);
    // becuase beg and end are equal, overwriting end with actual value
    gfq(beg,&end);
    printf("M %f %f %f\n",et2jd(beg),r2d(end),r2d(sunminangle(beg,planetcount,planets)));
  }
}

int main (int argc, char **argv) {

  SpiceInt i, nres;
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);
  SpiceDouble beg,end;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // this is wasteful, but I don't want to rewrite code
  planets[0] = 0;

  // planets array and count
  for (i=1; i<argc; i++) {planets[i] = atoi(argv[i]);}
  planetcount = argc;

  printf("CONJUNCTIONS FOR %f degrees, planets: %d %d %d %d %d %d\n",r2d(MAXSEP),(int)planets[1],(int)planets[2],(int)planets[3],(int)planets[4],(int)planets[5],(int)planets[6]);

  // TODO: make this switch based on argument

  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);
  //  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  // find under MAXSEP degrees...
  //  gfuds_c(gfq,gfdecrx,"<",MAXSEP,0.,86400.,MAXWIN,&cnfine,&result);

  gfdist_c ("1","NONE","0","LOCMIN",0,0,86400.,MAXWIN,&cnfine,&result);

  nres = wncard_c(&result);

  for (i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    // R = range, M = min
    printf("R %f %f\n",et2jd(beg),et2jd(end));
    findmins(beg,end);
  }

  //  printf("There are %d results\n",wncard_c(&result));

  return 0;
}
