// TODO: minimize includes

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <getopt.h>
#include <time.h>

/* 

97 = A, so 50+(c-97)/3 almost works since "0" = 48 and we're doing chars

113 = q, 122 = z, 63 is "?" (which we return for non-translatables)

*/

int convert_char(char c) {

  c = tolower(c);

  // things we can't convert including q and z (z case handled by c>121)
  if (c==113 || c<97 || c>121) {return 63;}

  // past Q
  if (c>113) {c--;}

  return 50+(c-97)/3;
}

char res[100];

int main(int argc, char **argv) {

  for (int i=1; i<argc; i++) {
    for (int j=0; j<strlen(argv[i]); j++) {
      // argv[i][j] = convert_char(argv[i][j]);
      res[j] = convert_char(argv[i][j]);
      //      printf("JUST SET %d to %d, now: %s\n", j, res[j], res);
      //      printf("ELT %d of %d is %d\n", i, j, convert_char(argv[i][j]));
    }

    res[strlen(argv[i])] = 0;
    printf("%s: %s\n", argv[i], res);
  }
}
