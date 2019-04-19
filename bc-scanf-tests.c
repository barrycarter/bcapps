#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {

  int val, res, i, ncols, nrows, nodata_value, count = 0;
  double xllcorner, yllcorner, cellsize;
  char str[100];

  // read first few lines of AAIgrid file

  for (i=0; i<12; i++) {
    scanf("%s", str);

    // pluck out the values I need
    if (i == 1) {
      ncols = atoi(str);
    } else if (i == 3) {
      nrows = atoi(str);
    } else if (i == 5) {
      xllcorner = atof(str);
    } else if (i == 7) {
      yllcorner = atof(str);
    } else if (i == 9) {
      cellsize = atof(str);
    } else if (i == 11) {
      nodata_value = atoi(str);
    } else {
      // do nothing
    }
  }

  printf("COLS: %d\nROWS: %d\nXLL: %f\nYLL: %f\nCS: %f\nND: %d\n",
	 ncols, nrows, xllcorner, yllcorner, cellsize, nodata_value);

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

  
