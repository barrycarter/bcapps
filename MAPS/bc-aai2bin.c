#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>

// NOTE: can put comments on end by appending to file after written

// To use, stdin should be aaigrid file

// -h number of headerlines (if not 6)

int main(int argc, char **argv) {

  signed long long val, res, i, j, ncols, nrows, nodata_value, adjlat, adjlon;
  signed long long dataSize, byte, opt, count = 0, headerLines = 6;
  FILE *fd;
  double xllcorner, yllcorner, cellsize;
  char str[100];

  // look at the opts
  while((opt = getopt(argc, argv, "h:")) != -1)  {
    headerLines = atoi(optarg);
  }

  // removed error checking because it's harder with option parsing
  // open the output file
  fd = fopen(argv[optind], "r+");

  // read first few lines of AAIgrid file for metadata

  for (i=0; i< 2*headerLines; i++) {
    scanf("%s", str);

    // pluck out the values I need
    if (i == 1) {
      ncols = atoi(str);
      printf("Setting ncols to %d\n", ncols);
    } else if (i == 3) {
      nrows = atoi(str);
      printf("Setting nrows to %d\n", nrows);
    } else if (i == 5) {
      xllcorner = atof(str);
      printf("Setting xllcorner to %f\n", xllcorner);
    } else if (i == 7) {
      yllcorner = atof(str);
      printf("Setting yllcorner to %f\n", yllcorner);
    } else if (i == 9) {
      cellsize = atof(str);
      printf("Setting cellsize to %f\n", cellsize);
    } else if (i == 11) {
      nodata_value = atoi(str);
      printf("Setting nodata_value to %d\n", nodata_value);
    } else {
      // do nothing
    }
  }

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

  // print some information on the values we've computed

  printf("\
WARNING: ASSUMING SOME VALUES BASED ON META DATA\n\
HEADER LINES: %lli\n\
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
	 headerLines, ncols, nrows, xllcorner, yllcorner, cellsize, nodata_value,
	 dataPerDegree, dataSize, addToData);


  // print some information about the bigger file we're inserting into

  // the +1 below allows for data points at +90 and -90 and data
  // points at +180 and -180 even those these are the same

  signed long long bigrows = 180*dataPerDegree+1;
  signed long long bigcols = 360*dataPerDegree+1;
  signed long long size = bigrows*bigcols*dataSize;

  printf("Output file rows: %lli\nOutput file cols: %lli\n\
Output file size: %lli bytes (%lli MB, %lli GB)\n", 
	 bigrows, bigcols, size, size/1000000, size/1000000000);

  printf("\n");

  // TODO: test output file size (+ get on argv)
  
  for (i=0; i < nrows; i++) {

    if (i%100==0) {printf("ROW: %lli / %lli\n", i, nrows);}

    // this computation is JFF
    double lat = yllcorner + cellsize*(nrows - i - 1/2);

    // compute big matrix row for this latitude/row
    // +90 to make it positive and then just multiply by dataPerDegree

    adjlat = (yllcorner + cellsize*(nrows - i - 1/2) + 90)*dataPerDegree;

    if (adjlat < 0 || adjlat > bigrows) {
      printf("BAD LATITUDE: %lli\n", adjlat);
      continue;
    }

    for (j=0; j < ncols; j++) {

      // JFF and debugging
      double lon = xllcorner + cellsize*(j+1/2);

      // TODO: computing this each time is inefficient
      // +180 to make it positive and then mult by dataPerDegree

      adjlon = (xllcorner + cellsize*(j+1/2) + 180)*dataPerDegree;

      // this test is unnecessary, technically
      if (adjlon < 0 || adjlon > bigcols) {
	printf("BAD LONGITUDE: %lli\n", adjlon);
	continue;
      }

      // the byte where we will write this

      byte = (adjlat*bigcols + adjlon)*dataSize;

      if (byte < 0 || byte > size) {
	printf("I: %lli, J: %lli, ADJLAT: %lli, ADJLON: %lli\n", i, j, adjlat, adjlon);
	printf("Attempt to print to invalid byte: %lli\n", byte);
	continue;
      }

      // seek to position
      fseek(fd, byte, SEEK_SET);

      // read value from stdin and add to it as needed
      
      scanf("%lli", &val);
      val += addToData;

      //      printf("I: %lli, J: %lli, LAT: %f, LON: %f, BYTE: %lli, VAL: %lli\n", i, j, lat, lon, byte, val);

      // convert val to 8 or 16 bit string

      if (dataSize == 1) {

	if (val < 0) {
	  printf("VAL < 0, using 0: %lli\n", val);
	  val = 0;
	}

	if (val > 255) {
	  printf("VAL > 255, using 255: %lli\n", val);
	  val = 255;
	}

	fputc(val, fd);
    } else if (dataSize == 2) {

	if (val < 0) {
	  printf("VAL < 0, using 0: %lli\n", val);
	  val = 0;
	}

	if (val > 65535) {
	  printf("VAL > 65535, using 65535: %lli\n", val);
	  val = 255;
	}

	fputc(val/256, fd);
	fputc(val%256, fd);
      }
    }
  }
  return 0;
}


  
