// find barycentric periapses and apoapses(?) for planet with the
// secondary goal of templating use of SPICE libraries

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/helpers.h"
#define MAXSEP 0.10471975511965977462
#define MAXWIN 1000000

// even if we're using something other than gfevnt_c, we need to
// define this to get a value (ugly!) [so we always run gfevnt_c?]

void gfq (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"J2000","NONE",0,v,&lt);
  *value = vnorm_c(v);
}

void gfq2 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"J2000","NONE",10,v,&lt);
  *value = vnorm_c(v);
}

// given a prefix (string), window (collection of intervals) and a
// function, display (print) the value of the function at each
// endpoint of each interval with prefix (which I will use to tell me
// what I am computing)

void show_results (char *prefix, SpiceCell result, 
		   void(* udfuns)(SpiceDouble et,SpiceDouble * value)) {

  SpiceInt i;
  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end, vbeg, vend;

  for (i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    udfuns(beg,&vbeg);
    udfuns(end,&vend);
    printf("%s %f %f %f %f\n",prefix,et2jd(beg),et2jd(end),vbeg,vend);
  }
}

// these are "globally" scoped
SpiceInt planets[7], planetcount;

// this just takes differentials of gfq
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  SpiceDouble dt = 10.;
  uddc_c( udfuns, et, dt, isdecr );
  return;
}

int main (int argc, char **argv) {

  SpiceInt i;
  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);

  // this is wasteful, but I don't want to rewrite code
  planets[0] = 0;

  // planets array and count
  for (i=1; i<argc; i++) {planets[i] = atoi(argv[i]);}
  planetcount = argc;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // TODO: make this switch based on argument
  wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);
  //  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("min-bc-to-mercury",result,gfq);

  gfuds_c(gfq2,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("min-sun-to-mercury",result,gfq);

  gfuds_c(gfq2,gfdecrx,"LOCMAX",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("max-sun-to-mercury",result,gfq);

  gfuds_c(gfq2,gfdecrx,"LOCMAX",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("max-sun-to-mercury",result,gfq);

  return(0);
}
