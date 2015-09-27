// find barycentric periapses and apoapses(?) for planet with the
// secondary goal of templating use of SPICE libraries

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "SpiceZpr.h"
// this the wrong way to do things
#include "/home/barrycarter/BCGIT/ASTRO/bclib.h"
#define MAXSEP 0.10471975511965977462
#define MAXWIN 1000000

// this lets me change function definition and times in all place
#define GFQ gfq2
#define REF "J2000"
#define COND "LOCMIN"
#define LABEL "mercury-peri"
// these are only approx!
// DE431 starts -13199.6509168566, ends 17191.1606672279 is my scheme
#define SYEAR -13199
#define EYEAR 17191

// file scope variables
char s[5000];

// array of stars (ra/dec)
double star[][3] = {
  {10.1396, 11.9672},
  {13.4199, -11.1612},
  {16.4901, -26.4319},
  {2.11952, 23.4628},
  {0,0},
  {6,23},
  {18,-23}
};

// current star
double curstar[3];

// even if we're using something other than gfevnt_c, we need to
// define this to get a value (ugly!) [so we always run gfevnt_c?]

// http://astronomy.stackexchange.com/questions/11917/was-there-ever-a-jupiter-transit-or-saturn-transit

void gfq5 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble u[3], v[3], lt;
  spkezp_c(10,et,REF,"NONE",601,u,&lt);
  spkezp_c( 5,et,REF,"NONE",601,v,&lt);

  // set global variable "s" to extra data, caller not required to use it

  // This is really ugly; if global variable 'extra' is set, print out
  // extra information; this should only be used when printing results
  // NOT during the search phase (TODO: this is ugly, better way?)

    if (vnorm_c(u)<vnorm_c(v)) {
      strcpy(s, "SUN IS CLOSER");
    } else {
      strcpy(s, "POSSIBLE TRANSIT");
    }

  *value = vsep_c(u,v)*180./pi_c();
}

void gfq (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"J2000","NONE",0,v,&lt);
  *value = vnorm_c(v);
}

void gfq2 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"J2000","NONE",10,v,&lt);

  sprintf(s,"%f %f %f",v[0],v[1],v[2]);

  *value = vnorm_c(v);
}

void gfq3 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;
  spkezp_c(1,et,"ECLIPJ2000","NONE",10,v,&lt);
  *value = v[1];
}

void gfq4 (SpiceDouble et, SpiceDouble *value) {
  SpiceDouble v[3], lt;

  // angular distance between Mars (for now) + globally defined curstar vector
  spkezp_c(4,et,"J2000","NONE",399,v,&lt);

  *value = vsep_c(v,curstar);
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
    printf("%s %f %f %f %f '%s'\n",prefix,et2jd(beg),et2jd(end),vbeg,vend,s);
  }
}

// this just takes differentials of whatever function is fed to it
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
  wninsd_c((SYEAR-2000.)*31556952.,(EYEAR-2000.)*31556952.,&cnfine);

  // all of DE431
  // wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  // NOTE: putting MAXSEP below is harmless if cond is LOCMIN or something
  gfuds_c(GFQ,gfdecrx,COND,MAXSEP,0.,86400.,MAXWIN,&cnfine,&result);
  show_results(LABEL,result,GFQ);

  return(0);
}
