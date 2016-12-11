// Attempts to re-create the functions I had in Mathematica, just so I
// can get a hang of the SPICE C kernel (have been trying to do too
// much w/ it?)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SpiceUsr.h"
#include "SpiceZfc.h"
#include "bclib.h"

// Return the true (not mean) matrix of transformation from EQEQDATE
// to ECLIPDATE at time et

void eqeq2eclip(SpiceDouble et, SpiceDouble matrix[3][3]) {

  SpiceDouble nut, obq, dobq, sobq, cobq;

  // these functions are nonstandard, don't end with "c" and take et
  // as a pointer

  zzwahr_(&et, &nut);
  zzmobliq_(&et, &obq, &dobq);

  // sin and cos of angle of transformation
  sobq = sin(obq+nut);
  cobq = cos(obq+nut);

  // this is just plain ugly
  matrix[0][0] = 1;
  matrix[0][1] = 0;
  matrix[0][2] = 0;
  matrix[1][0] = 0;
  matrix[1][1] = cobq;
  matrix[1][2] = sobq;
  matrix[2][0] = 0;
  matrix[2][1] = -cobq;
  matrix[2][2] = sobq;

  for (int i=0; i<=2; i++) {
    for (int j=0; j<=2; j++) {
      printf("FOO: %d %d %f\n",i,j,matrix[i][j]);
    }
  }

  printf("ENDS THIS ROUTINE %p\n", matrix);

}

int main (int argc, char **argv) {

  SpiceDouble et, mat[3][3], mat2[3][3], nut, obq, dboq;
  SpiceDouble pos[3];
  SpiceDouble lt;
  SpiceInt planets[6], i;

  // TODO: seriously clean up my frame numbering
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/standard.tm");
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/ECLIPDATE1.TF");
  furnsh_c("/home/barrycarter/BCGIT/ASTRO/eqeqdate.tf");

  et = year2et(2000);

  zzwahr_(&et, &nut);
  zzmobliq_(&et, &obq, &dboq);

  printf("NUTATION: %f\n", nut);
  printf("OBLIQUITY: %f\n", obq);

  pxform_c("EQEQDATE", "ECLIPDATE", et, mat);

  for (i=0; i<=2; i++) {
    printf("ALPHA: %d %f %f %f\n", i, mat[i][0], mat[i][1], mat[i][2]);
  }

  eqeq2eclip(et, mat2);

  printf("ALPHATEST\n");

  for (i=0; i<=2; i++) {
    printf("BETA: %d %f %f %f\n", i, mat2[i][0], mat2[i][1], mat2[i][2]);
  }


  exit(0);

  char test2[2000];

  str2et_c("10400-FEB-28 00:00:00", &et);
  printf("ET: %f\n", et);
  str2et_c("10400-MAR-01 00:00:00", &et);
  printf("ET: %f\n", et);


  exit(0);



  timout_c(0, "ERAYYYY##-MON-DD HR:MN:SC.############# ::MCAL", 41, test2);

  printf("%s\n", test2);

  exit(0);

  long long test = -pow(2,63);

  printf("TEST: %lld\n",test);

  exit(0);


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
