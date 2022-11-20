#include <stdio.h>

int main (int argc, char **argv) {

  int x,y,z;
  long long count=0;

  for (x=-1000; x<=1000; x++) {
    printf("X: %d, COUNT: %lu\n", x, count);
    for (y=-1000; y<=1000; y++) {
      for (z=-1000; z<=1000; z++) {
	if (2*x - 3*y > 5*z) {count++;}
      }
    }
  }

  printf("COUNT: %lu\n", count);

}

