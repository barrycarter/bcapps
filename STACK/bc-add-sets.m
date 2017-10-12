(*

https://stackoverflow.com/questions/46629934/given-a-pair-of-integers-minimum-of-operations-performed-to-reach-target-n

Given a set {A,B} we can go to {A+B, B} or {A, A+B} start with {1,1} get to A=N or B=N

f[{a_,b_}] = DeleteDuplicates[{{a+b,b},{a,a+b}}]

s[0] = {{1,1}}

s[n_] := s[n] = Flatten[Map[f,s[n-1]],1]

t[n_] := Sort[DeleteDuplicates[Flatten[s[n]]]]



integers first reached at s[n]

1: s[0]
2: s[1]
3: s[2]
4: s[3]
5: s[3]
6: s[5]
7: s[3]
8: s[3]
9: s[5]
10: s[5]
11: s[5]
12: s[5]
13: s[5]

1,2,3,3,5,3,3,5,5,5,5,5

A+B = N or B = N or A = N or A+B = N

{65, ?} or {?, 65} means you had {x, y} or {y, x} with x+y = 65

for example {25, 40} or {40, 25} which itself must've come from

A+B = 25, B = 40 

A = 25, A+B = 40

%%%%%%%%%

[I wrote this before I realized @mark-dickinson had answered; his answer is much better than mine, but I'm providing mine for reference anyway]

The problem is fairly easy to solve if you work backwards. As an example, suppose N=65: 

  - That means our current pair is either {65, x} or {y, 65} for some unknown values of x and y.

  - If {A,B} was the previous pair, this means either {A, A+B} or {A+B, B} is equal to either {65, x} or {y, 65}, which gives us 4 possible cases:

    - {A,A+B} = {65,x}, which would mean A=65. However, if A=65, we would've already hit A=N at an earlier step, and we're assuming this is the first step at which A=N or B=N, so we discard this possibility.

    - {A,A+B} = {y,65} which means A+B=65

    - {A+B,B} = {65,x} which means A+B=65

    - {A+B,B} = {y,65} which means B=65. However, if B=65, we already had a solution at a previous step, we also discard this possibility.

Therefore, A+B=65. There are 65 ways in which this can happen (actually, I think you can ignore the cases where A=0 or B=0, and also choose B>A by symmetry, but the solution is easy even withouth these assumptions).

  - We now examine all 65 cases. As an example, let's use A=25 and B=40.

  - If {C,D} was the pair that generated {25,40}, there are two possible cases:

    - {C+D,D} = {25,40} so D=40 and C=-15, which is impossible, since, starting at {1,1}, we will never get negative numbers.

    - {C,C+D} = {25,40} so C=25, and D=15.

  - Therefore, the "predecessor" of {25,40} is necessarily {25,15}.

  - By similar analysis, the predecessor of {25,15}, let's call it {E,F}, must have the property that either:

    - {E,E+F} = {25,15}, impossible since this would mean F=-10

    - {E+F,F} = {25,15} meaning E=10 and F=15.

  - Similarly the predecessor of {10,15} is {10,5}, whose predecessor is {5,5}.

  - The predecessor of {5,5} is either {0,5} or {5,0}. These two pairs are their own predecessors, but have no other predecessors.

  - Since we never hit {1,1} in this sequence, we know that {1,1} will never generate {25, 40}, so we continue computing for other pairs {A,B} such that A+B=65.

  - If we did hit {1,1}, we'd count the number of steps it took to get there, store the value, compute it for all other values of {A,B} such that A+B=65, and take the minimum.

Note that once we've chosen a value of A (and thus a value of B), we are effectively doing the subtraction version of [Euclid's Algorithm](https://en.wikipedia.org/wiki/Euclidean_algorithm#Implementations), so the number of steps required is O(log(N)). Since you are doing these steps N times, the algorithm is O(N*log(N)), much smaller than your O(2^N).

Of course, you may be able to find shortcuts to make the method even faster.

Interesting Notes
-----------------

If you start with {1,1}, here are the pairs you can generate in k steps (we use k=0 for {1,1} itself), after removing duplicates:

k=0: {1,1}

k=1: {2, 1}, {1, 2}

k=2: {3, 1}, {2, 3}, {3, 2}, {1, 3}

k=3: {4, 1}, {3, 4}, {5, 3}, {2, 5}, {5, 2}, {3, 5}, {4, 3}, {1, 4}

k=4: {5, 1}, {4, 5}, {7, 4}, {3, 7}, {8, 3}, {5, 8}, {7, 5}, {2, 7}, {7, 2}, {5, 7}, {8, 5}, {3, 8}, {7, 3}, {4, 7}, {5, 4}, {1, 5}

k=5: {6, 1}, {5, 6}, {9, 5}, {4, 9}, {11, 4}, {7, 11}, {10, 7}, {3, 10}, {11, 3}, {8, 11}, {13, 8}, {5, 13}, {12, 5}, {7, 12}, {9, 7}, {2, 9}, {9, 2}, {7, 9}, {12, 7}, {5, 12}, {13, 5}, {8, 13}, {11, 8}, {3, 11},  {10, 3}, {7, 10}, {11, 7}, {4, 11}, {9, 4}, {5, 9}, {6, 5}, {1, 6}

Things to note:

  - You can generate N=7 and N=8 in 4 steps, but not N=6, which requires 5 steps.

  - Because of duplication, the number of pairs at the kth step isn't O(2^k), but rather O(gamma^k), where gamma is the Golden Ratio(https://en.wikipedia.org/wiki/Golden_ratio). This isn't particularly surprising since we generate the pairs in a Fibonacci-esque way.

  - The smallest number of steps (k) required to reach a given N is:

N=1: k=0

N=2: k=1

N=3: k=2

N=4: k=3

N=5: k=3

N=6: k=5

N=7: k=4

N=8: k=4

N=9: k=5

N=10: k=5

N=11: k=5

The resulting sequence, {0,1,2,3,3,5,4,4,5,5,5,...} is https://oeis.org/A178047

WRONG: The number of pairs generated at step k forms the sequence {1, 2, 3, 5, 7, 13, 20, 31, 48, 78, 118, 191, 300, 465, 734, 1175, 1850, 2926, 4597, 7296, 11552, 18278, 28863, 45832, 72356, 114742, ...}, which does not appear in OEIS (I will look into adding it).

NOTE: above is number of distinct integers reachable in k steps

For details on how I worked this problem out, see https://github.com/barrycarter/bcapps/blob/master/STACK/bc-add-sets.m

