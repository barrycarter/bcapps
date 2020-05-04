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

    for (i = 0; i < fcount; i++) {
      printf("s(%d): %s\n", i, s[i]);
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
