// find barycentric periapses and apoapses(?) for planet with the
// secondary goal of templating use of SPICE libraries

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"
#define MAXSEP 0.10471975511965977462
#define MAXWIN 1000000

// file scope variables
double star[2][3] = { {1,0,0}, {-1,0,0} };

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

void gfq3 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"ECLIPJ2000","NONE",10,v,&lt);
  *value = v[1];
}

void gfq4 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;

  // angular distance between Mars (for now) + globally defined star vector
  spkezp_c(4,et,"J2000","NONE",399,v,&lt);

  *value = vsep_c(v,star);
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

// this just takes differentials of gfq
void gfdecrx (void(* udfuns)(SpiceDouble et,SpiceDouble * value),
              SpiceDouble et, SpiceBoolean * isdecr ) {
  SpiceDouble dt = 10.;
  uddc_c( udfuns, et, dt, isdecr );
  return;
}

int main (int argc, char **argv) {

  SPICEDOUBLE_CELL(cnfine,2);
  SPICEDOUBLE_CELL(result,2*MAXWIN);

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  // TODO: make this switch based on argument

  // Unix time, 1970-2034
  // wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);

  // 1901-2100ish
  wninsd_c(unix2et(-70*366*86400.),unix2et(2147483647+70*366*86400.),&cnfine);

  // test for star sep

  gfuds_c(gfq4,gfdecrx,"<",MAXSEP,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("star-test-zero",result,gfq4);
  
  return(0);

  // all of DE431
  // wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  gfuds_c(gfq3,gfdecrx,"=",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("bc-sun-eclip-x-zero",result,gfq3);

  gfuds_c(gfq,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("min-bc-to-mercury",result,gfq);

  gfuds_c(gfq2,gfdecrx,"LOCMIN",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("min-sun-to-mercury",result,gfq2);

  gfuds_c(gfq2,gfdecrx,"LOCMAX",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("max-sun-to-mercury",result,gfq);

  gfuds_c(gfq2,gfdecrx,"LOCMAX",0.,0.,86400.,MAXWIN,&cnfine,&result);
  show_results("max-sun-to-mercury",result,gfq2);

  return(0);
}
