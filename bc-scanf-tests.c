#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// To use, stdin should be aaigrid file

int main(int argc, char **argv) {

  signed long long val, res, i, j, ncols, nrows, nodata_value, adjlat, adjlon;
  signed long long dataSize, count = 0;
  double xllcorner, yllcorner, cellsize;
  char str[100];

  // we reserve the first 1M bytes for comments
  signed long long reserve = 1000000;

  // read first few lines of AAIgrid file for metadata

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

  printf("%d %lli\n", nodata_value, nodata_value);

  // TODO: assuming these values is dangerous

  signed long long dataPerDegree = round(1/cellsize);
  signed long long addToData = -nodata_value;

  // this is really really bad

  if (nodata_value == -9999) {
    dataSize = 2;
  } else if (nodata_value == 0) {
    dataSize = 1;
  } else {
    printf("Can't figure out dataSize from nodata_value %d\n", nodata_value);
    return -1;
  }

  printf("\
WARNING: ASSUMING SOME VALUES BASED ON META DATA\n\
COLS: %lli\n\
ROWS: %lli\n\
XLL: %f\n\
YLL: %f\n\
Cell Size: %f\n\
No Data Value: %lli\n\
Data points per degree: %lli\n\
Bytes per data point: %lli\n\
Data add factor: %lli\n\
",
	 ncols, nrows, xllcorner, yllcorner, cellsize, nodata_value,
	 dataPerDegree, dataSize, addToData);

  // this is just to be more like bc-srtm2bin.pl

  printf("Output file size minimum: %lli\n", 360*180*dataPerDegree*dataPerDegree*dataSize + reserve);

  // TODO: test output file size (+ get on argv)
  

  // speed test here
  for (i=0; i < nrows; i++) {

    // compute matrix point for this latitude/row

    // first compute the latitude
    adjlat = yllcorner + cellsize*(nrows - i - 1/2);

    

    

    for (j=0; j < ncols; j++) {

      // TODO: computing this each time is redundant
      adjlon = xllcorner + cellsize*(j+1/2);

      // read value from stdin
      scanf("%lli", &val);


    }
  }

  return -1;

  while (!feof(stdin)) {
    //    res = scanf("%lli", &val);
    scanf("%lli", &val);
    count++;
    //    printf("%lli: %lli,%lli\n", count, val/256, val%256);
    printf("%lli: %lli (%lli)\n", count, val, res);
    // val = -99999999;
  }

  return 0;
}

  
