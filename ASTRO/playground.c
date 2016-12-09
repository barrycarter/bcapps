// Attempts to re-create the functions I had in Mathematica, just so I
// can get a hang of the SPICE C kernel (have been trying to do too
// much w/ it?)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"

// actually declaring entire functions here, not just prototype
double et2jd(double d) {return 2451545.+d/86400.;}
double jd2et(double d) {return 86400.*(d-2451545.);}

// icky defining functions first

void posxyz(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  spkezp_c(planet, jd2et(time),"J2000","NONE",0,position,&lt);
}

void earthvector(double time, int planet, SpiceDouble position[3]) {
  SpiceDouble lt;
  // TODO: make this 399 for production
  spkezp_c(planet, jd2et(time),"J2000","NONE",3,position,&lt);
}

double earthangle(double time, int p1, int p2) {
  SpiceDouble pos[3], pos2[3];
  earthvector(time, p1, pos);
  earthvector(time, p2, pos2);
  return vsep_c(pos,pos2);
}

double earthmaxangle(double time, int arrsize, SpiceInt *planets) {
  double max, sep;

  int i,j;

  for (i=0; i<arrsize; i++) {
    for (j=i+1; j<arrsize; j++) {
      sep = earthangle(time, planets[i], planets[j]);
      if (sep>max) {max=sep;}
    }
  }
  return max;
}

int main (int argc, char **argv) {

  long long test = -pow(2,63);

  printf("TEST: %lld\n",test);

  exit(0);


  SpiceDouble pos[3];
  SpiceDouble lt;
  SpiceInt planets[6], i;

  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");

  if (!strcmp(argv[1],"posxyz")) {
    double time = atof(argv[2]);
    int planet = atoi(argv[3]);
    posxyz(time,planet,pos);
    printf("%f -> %f %f %f\n",time,pos[0],pos[1],pos[2]);
  };

  if (!strcmp(argv[1],"earthvector")) {
    double time = atof(argv[2]);
    int planet = atoi(argv[3]);
    earthvector(time,planet,pos);
    printf("%f -> %f %f %f\n",time,pos[0],pos[1],pos[2]);
  };

  if (!strcmp(argv[1],"earthangle")) {
    double time = atof(argv[2]);
    int p1 = atoi(argv[3]);
    int p2 = atoi(argv[4]);
    SpiceDouble sep = earthangle(time,p1,p2);
    printf("%f -> %f\n",time,sep);
  };

  if (!strcmp(argv[1],"earthmaxangle")) {
    double time = atof(argv[2]);
    for (i=3; i<argc; i++) {planets[i-3] = atoi(argv[i]);}
    SpiceDouble sep = earthmaxangle(time,argc-3,planets);
    printf("%f -> %f\n",time,sep);
  };

}
