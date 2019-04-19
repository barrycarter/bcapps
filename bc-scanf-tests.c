#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {

  int val, res, i, count = 0;
  double dval;
  char str[100];

  // read first few lines of AAIgrid file

  for (i=0; i<7; i++) {
    scanf("%s", str);
    printf("STRING: %s\n", str);
    scanf("%f", &dval);
    printf("FLOAT: %f\n", dval);
  }

  return -1;

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

  
