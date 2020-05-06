#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "/home/user/BCGIT/ASTRO/bclib.h"

/*

Notes: 

  - not all stars have const values in hygdata

*/

int main(int argc, char **argv) {

  char line[10000], s[100][500];
  int i;
  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");


  FILE *fh = popen("zcat /home/user/BCGIT/ASTRO/hygdata_v3.csv.gz", "r");

  // print header lines

  printf("id,filecon,curcon,oldcon\n");

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

      s[fcount][ccount] = line[i];
      ccount++;
    }

    s[fcount][ccount] = '\0';

    // fields we want:

    // 0=id, 13=mag 7=ra, 8=dec, 10=pmra, 11=pmdec

    int id = atoi(s[0]);
    double ra = atof(s[7]), dec = atof(s[8]);

    // in milliarcseconds 
    double pmra = atof(s[10]), pmdec = atof(s[11]);

    // 1: given in file, 2: current ra/dec (precessed), 3: ra/dec of
    // 1850 (precessed

    char aster1[40], aster2[40], aster3[40];

    // from file
    strcpy(aster1, s[29]);



    // upcase it
    aster1[1] = toupper(aster1[1]);
    aster1[2] = toupper(aster1[2]);

    // find constellation for current ra/dec

    strcpy(aster2, constellationName(constellationNumber(ra/12*pi_c(), dec/180*pi_c())));

    // find old ra and dec
    
    // milliarcsecond = ? in hours; 1 hour = 15deg, 1/15/3600/1000

    double oldra = ra - pmra*150/54000000;
    double olddec = dec - pmdec*150/3600000;

    strcpy(aster3, constellationName(constellationNumber(oldra/12*pi_c(), olddec/180*pi_c())));

    if (oldra < 0) {oldra += 24;}

    // skip case where aster1 (from file) is empty
    if (!strcmp(aster1, "")) {continue;}

    // skip Sun
    if (id == 0) {continue;}

    if (strcasecmp(aster2, aster3) || strcasecmp(aster1, aster2) || strcasecmp(aster1, aster3)) {
      printf("%06d,%s,%s,%s\n", id, aster1, aster2, aster3);
    }
  }
}

