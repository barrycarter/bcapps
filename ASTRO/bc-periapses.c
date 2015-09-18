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

// given a prefix (string), window (collection of intervals) and a
// function, display (print) the value of the function at each
// endpoint of each interval with prefix (which I will use to tell me
// what I am computing)

void show_results (char *prefix, SpiceCell result, 
		   void(* udfuns)(SpiceDouble et,SpiceDouble * value)) {

  SpiceInt i;
  SpiceInt nres = wncard_c(&result);
  SpiceDouble beg, end, vbeg, vend;

  printf("CALLED!\n");

  for (i=0; i<nres; i++) {
    wnfetd_c(&result,i,&beg,&end);
    udfuns(beg,&vbeg);
    udfuns(end,&vend);
    printf("%s %f %f %f %f\n",prefix,beg,end,vbeg,vend);
  }
}

// even if we're using something other than gfevnt_c, we need to
// define this to get a value (ugly!) [so we always run gfevnt_c?]

void gfq (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"J2000","NONE",0,v,&lt);
  printf("RETURNING: %f\n",*value);
  *value = vnorm_c(v);
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

  //  gfdist_c("1","NONE","0","LOCMIN",0,0,86400.,MAXWIN,&cnfine,&result);

  show_results("prefix",result,gfq);

  return(0);

  //  printf("CONJUNCTIONS FOR %f degrees, planets: %d %d %d %d %d %d\n",r2d(MAXSEP),(int)planets[1],(int)planets[2],(int)planets[3],(int)planets[4],(int)planets[5],(int)planets[6]);

  // find under MAXSEP degrees...
  //  gfuds_c(gfq,gfdecrx,"<",MAXSEP,0.,86400.,MAXWIN,&cnfine,&result);


  //  nres = wncard_c(&result);

  //  for (i=0; i<nres; i++) {
  //    wnfetd_c(&result,i,&beg,&end);
    // R = range, M = min
  //    printf("R %f %f\n",et2jd(beg),et2jd(end));
  //    findmins(beg,end);
  //  }

  //  printf("There are %d results\n",wncard_c(&result));

  //  return 0;
}
