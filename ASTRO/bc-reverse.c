// an attempt to rewrite "reverse" command which chokes fatally on
// multi-byte chars; this program doesnt really belong here, but it's
// just easier since I have everything set up to compile C here

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char **argv) {

  char str[1000000];

  while (scanf("%s", str) > 0) {
    printf("STRING: %s\n", str);
  }

}

