#include <stdio.h>
#include <stdlib.h>
#include "/home/user/BCGIT/ASTRO/bclib.h"

/*

To use this program, uncompress bc-stars.c.bz2 and put it in /tmp/bc-stars.c

To create the bc-stars.c file in the first place I did:

zcat hygdata_v3.csv.gz | perl -F, -anle 'if ($F[29] eq "") {next;} $F[29] = uc($F[29]); print "printf(\"$F[0] $F[29] %s\\n\", constellation($F[7]*15/180*pi_c(), $F[8]/180*pi_c()));"' | tail -n +2 > /tmp/bc-stars.c

which basically prints the HYG id and constellation of each star
 followed by the computed constellation of each star

*/

// TODO: undo comment above

int main(int argc, char **argv) {

  char line[10000], s[100][500];
  int i;
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");


  FILE *fh = popen("zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "r");

  while (!feof(fh)) {

    fgets(line, 10000, fh);

    int fcount = 0, ccount = 0;

    for (i=0; i < strlen(line); i++) {

      if (line[i] == ',') {
	s[fcount][ccount] = '\0';
	fcount++;
	ccount = 0;
	continue;
      }

      //      printf("s[%d][%d] -> %c\n", fcount, ccount, line[i]);
      s[fcount][ccount] = line[i];
      ccount++;
    }

    s[fcount][ccount] = '\0';

    // fields we want:
    // 0=id, 13=mag 7=ra, 8=dec, 17-22 are xyz vxvyvz, 

    int id = atoi(s[0]);
    double ra = atof(s[7]), dec = atof(s[8]);
    double x = atof(s[17]), y = atof(s[18]), z = atof(s[19]);
    double vx = atof(s[20]), vy = atof(s[21]), vz = atof(s[22]);
    char aster[40];
    strcpy(aster, s[29]);


    printf("29: %s\n", s[29]);

    double dist = sqrt(x*x + y*y + z*z);

    //    double zc = asin(z/dist);

    double rac = atan2(y,x)/pi_c()*12;

    double oldra, olddec;

    j2000tob1875(ra/12*pi_c(), dec/180*pi_c(), &oldra, &olddec);
    oldra *= 12/pi_c();
    olddec *= 180/pi_c();

    if (oldra < 0) {oldra += 24;}

    printf("%d %s %f %f %f %f %s\n", id, constellationName(constellationNumber(ra, dec)), ra, dec, oldra, olddec, aster);

    //    printf("DRA: %f\n", abs(ra-rac));

    //    printf("DIST: %f, RA: %f, DEC: %f, X: %f, Y: %f, Z: %f\n", dist, ra, dec, x, y, z);
    // printf("RA: %f, RAC: %f, DEC: %f, X: %f, Y: %f, Z: %f\n", ra, rac/pi_c()*12, dec, x, y, z);

    for (i = 0; i <= fcount; i++) {
      //      printf("s(%d): %s\n", i, s[i]);
    }

    //    printf("S0: %s\nS1: %s\nS2: %s\n", s[0], s[1], s[2]);
  }
}

    /*
    printf("LINE: %s\n", line);

    int pos = 0, oldpos = 0;

    for (int i = 0; i<10; i++) {

      pos = strchr(&line[oldpos], ',') - line + 1;
      strncpy(s, &line[oldpos], pos-oldpos);

      s[pos-oldpos] = 0;

      printf("S: %s O: %d N: %d\n", s, oldpos, pos);

      oldpos = pos;
    */
