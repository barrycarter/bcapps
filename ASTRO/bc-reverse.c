// an attempt to rewrite "reverse" command which chokes fatally on
// multi-byte chars; this program doesnt really belong here, but it's
// just easier since I have everything set up to compile C here

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char **argv) {

  char str[1000000];

  while (!feof(stdin)) {

    if (fgets(str, 100000, stdin) == NULL) {continue;}

    // the -2 here is to avoid the ending newline

    for (int i=strlen(str)-2; i>=0; i--) {printf("%c", str[i]);}

    printf("\n");
  }
}
