/**

Attempts to solve https://www.reddit.com/r/learnmath/comments/18i7z2n/problem_thats_been_bugging_me_for_a_while/

Treats the sequence aa,bb,cc,dd as the decimal number aabbccdd

Many sequences hit 13 steps (shown as 12 in output of code). Here are 50:

52281508
43196356
55799299
42329661
59119985
19069044
50371357
58839612
25447915
65214558
56342297
17048842
91102347
96866732
64993545
04793816
10456474
12588396
98102450
98845810
06132650
12347500
02463926
01426476
01826945
22108544
73293649
22975634
46708390
86796642
68491478
01365565
01164496
32678696
86401502
30065043
07204488
89703599
10234791
73665329
44516488
33777057
58238777
81912762
37150378
93867349
60258979
90061944
20079145
66428679

*/


// TODO: minimize includes

// below is for just transforms
// runtime sample: 12.755u 0.903s 0:15.24 89.5%    0+0k 0+3515632io 0pf+0w
// runtime sample: 12.125u 1.170s 0:24.78 53.6%    0+0k 104+3515632io 0pf+0w

// below is for cycle lengths + transforms
// 19.052u 1.288s 0:21.34 95.2%    0+0k 0+3515640io 0pf+0w

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <getopt.h>
#include <time.h>

int res[100000000];

int transform(int x) {
  int x1 = x/1000000;
  int x2 = (x%1000000)/10000;
  int x3 = (x%10000)/100;
  int x4 = x%100;
  return abs(x1-x2)*1000000 + abs(x2-x3)*10000 + abs(x3-x4)*100 + abs(x4-x1);
}

// assuming the res array is filled, computes the cycle length of a given sequence

int cycle_length(int x) {

  int count = 0;

  while (x = transform(x)) {count++;}

  return count;
}

int main(int argc, char **argv) {
  for (int i=0; i < 100000000; i++) {
    res[i] = transform(i);
    //    printf("%08d,%08d\n", i, transform(i));
  }

  for (int i=0; i < 100000000; i++) {
    printf("%08d,%08d\n", i, cycle_length(i));
  }
}


