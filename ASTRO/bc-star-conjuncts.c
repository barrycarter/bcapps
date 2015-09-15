#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#define MAXWIN 200000
#define MAXSEP 0.10471975511965977462

// Usage: $0 ra-of-star-radians dec-of-star-radians list-of-planet

// this starts out as a copy of bc-planet-conjuncts.c

// these are "globally" scoped
SpiceInt planets[7], planetcount;
SpiceDouble starpos[3];

// icky defining functions first

double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}
double unix2et(double d) {return d-946684800.;}
double r2d(double d) {return d*180./pi_c();}

void earthvector(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  SpiceInt i;

  // planet -1 is the star
  if (planet==-1) {
    for (i=0; i<=2; i++) {
      position[i] = starpos[i];
    }
    return;
  }

  spkezp_c(planet, time,"J2000","NONE",399,position,&lt);
}

double earthangle(double time, int p1, int p2) {
  SpiceDouble pos[3], pos2[3];
  earthvector(time, p1, pos);
  earthvector(time, p2, pos2);
  //  printf("GOT: %d %d %f %f %f\n",p1,p2,pos[0],pos[1],pos[2]);
  return vsep_c(pos,pos2);
}

double earthmaxangle(double time, int arrsize, SpiceInt *planets) {
  double max=0, sep;

  int i,j;

  for (i=0; i<arrsize; i++) {
    if (planets[i]==0) {continue;}
    for (j=i+1; j<arrsize; j++) {
      if (planets[j]==0) {continue;}
      sep = earthangle(time, planets[i], planets[j]);
      if (sep>max) {max=sep;}
    }
  }
  return max;
}

// min angle from sun of given planets at given time

double sunminangle(double time, int arrsize, SpiceInt *planets) {

  // max angle is actually pi/2, so 3.1416 is overkill
  double min=3.1416, sep;
  int i;

  for (i=0; i<arrsize; i++) {
    if (planets[i]==0) {continue;}
    sep = earthangle(time, planets[i], 10);
    if (sep<min) {min=sep;}
  }
  return min;
}

// function to minimize is earthmaxangle
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

  // this will represent the stars position
  planets[0] = -1;

  // convert ra and dec to starpos
  radrec_c(1,atof(argv[1]),atof(argv[2]),starpos);

  // planets array and count
  for (i=1; i<argc-2; i++) {planets[i] = atoi(argv[i+2]);}
  planetcount = argc-2;

  printf("CONJUNCTIONS FOR %f degrees, planets: %s %s %d %d %d %d %d %d\n",r2d(MAXSEP),argv[1],argv[2],(int)planets[1],(int)planets[2],(int)planets[3],(int)planets[4],(int)planets[5],(int)planets[6]);

  // TODO: this is for testing only
  // wninsd_c(unix2et(0),unix2et(2147483647),&cnfine);
  wninsd_c (-479695089600.+86400*468, 479386728000., &cnfine);

  // 1 second tolerance (serious overkill, but 1e-6 is default, worse!)
  gfstol_c(1.);

  // find under MAXSEP degrees...
  gfuds_c(gfq,gfdecrx,"<",MAXSEP,0.,86400.,MAXWIN,&cnfine,&result);

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
