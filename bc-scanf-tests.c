#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// To use, stdin should be aaigrid file

int main(int argc, char **argv) {

  signed long long val, res, i, j, ncols, nrows, nodata_value, adjlat, adjlon;
  signed long long dataSize, byte, count = 0;
  FILE *fd;
  double xllcorner, yllcorner, cellsize;
  char str[100];

  // the output file
  if (argc != 2) {
    printf("Usage: $0 outputfile\n");
    return -1;
  }


  // we reserve the first 1M bytes for comments
  signed long long reserve = 1000000;

  // open the output file
  fd = fopen(argv[1], "r+");

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

  // print some information on the values we've computed

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


  // print some information about the bigger file we're inserting into

  // the +1 below allows for data points at +90 and -90 and data
  // points at +180 and -180 even those these are the same

  signed long long bigrows = 180*dataPerDegree+1;
  signed long long bigcols = 360*dataPerDegree+1;
  signed long long size = bigrows*bigcols*dataSize + reserve;

  printf("Output file rows: %lli\nOutput file cols: %lli\n\
Reserved for comments: %lli\n\
Output file size: %lli bytes (%lli MB, %lli GB)\n", 
	 bigrows, bigcols, reserve, size, size/1000000, size/1000000000);

  printf("\n");

  // TODO: test output file size (+ get on argv)
  
  for (i=0; i < nrows; i++) {

    if (i%100==0) {printf("ROW: %lli / %lli\n", i, nrows);}

    // compute big matrix row for this latitude/row
    // +90 to make it positive and then just multiply by dataPerDegree

    adjlat = (yllcorner + cellsize*(nrows - i - 1/2) + 90)*dataPerDegree;

    if (adjlat < 0 || adjlat > bigrows) {
      printf("BAD LATITUDE: %lli\n", adjlat);
      continue;
    }

    for (j=0; j < ncols; j++) {

      // TODO: computing this each time is inefficient
      // +180 to make it positive and then mult byh dataPerDegree

      adjlon = (xllcorner + cellsize*(j+1/2) + 180)*dataPerDegree;

      // this test is unnecessary, technically
      if (adjlon < 0 || adjlon > bigcols) {
	printf("BAD LONGITUDE: %lli\n", adjlon);
	continue;
      }

      // the byte where we will write this

      byte = (adjlat*bigcols + adjlon)*dataSize + reserve;

      if (byte < 0 || byte > size) {
	printf("I: %lli, J: %lli, ADJLAT: %lli, ADJLON: %lli\n", i, j, adjlat, adjlon);
	printf("Attempt to print to invalid byte: %lli\n", byte);
	continue;
      }

      // seek to position
      lseek(fd, byte, SEEK_SET);

      // read value from stdin and add to it as needed
      
      scanf("%lli", &val);
      val += addToData;

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


  
