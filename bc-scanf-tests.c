#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {

  int val, res, count = 0;

  while (!feof(stdin)) {
    //    res = scanf("%d", &val);
    scanf("%d", &val);
    count++;
    //    printf("%d: %d,%d\n", count, val/256, val%256);
    printf("%d: %d (%d)\n", count, val, res);
    // val = -99999999;
  }

  return 0;
}

  
