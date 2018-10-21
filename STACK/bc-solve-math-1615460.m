(* Attempt to solve http://math.stackexchange.com/questions/1615460/expected-value-and-a-variance-of-a-die-sequence *)

(*

Using brute-force techniques
(https://github.com/barrycarter/bcapps/blob/master/MATHEMATICA/bc-solve-math-1615460.m),
I got the answer 470474386324001/18866716141824 which is
about 24.9367, slightly lower than the 25.5 value you'd get if you
did count repeats. This may seem strange since there's a 50% chance of
rolling a 5 or a 6, but the fact that we remove double 5s and double
6s seems to reduce the value more than enough to compensate.

Given the "complexity" of this answer, I don't think there's a
non-brute-force way to solve this problem, although I could be very
wrong.

My approach:

  - The probability distribution for the first roll is given, and the
  expected value happens to be 17/4.

  - If the first roll is a 2 (for example), the next number we record
  must be 1, 3, 4, 5, or 6, since we disallow repeats. The relative
  probabilities of these values are (0.05, 0.15, 0.2, 0.25, 0.25),
  which adds up to 0.9 (which we expect, since the probability of 2
  was 0.1). To turn these probabilities into absolute probabilities,
  we divide by 0.9 to get:
  $\left\{\frac{1}{18},0,\frac{1}{6},\frac{2}{9},\frac{5}{18},\frac{5}{18}\right\}$

  - So, the probability of rolling a 6 after you've rolled a 2 (for
  example) is 5/18.

  - Note that I've set the probability of rolling another 2 after the
  first 2 is 0, because you will never record a 2 following another 2.

  - Brute force computing the probability of recording an 'n' after an 'm':

[[TABLE]]

where the row is the first roll and the column is the second roll.

For example, to find the chance of rolling a 6 after you've rolled a
2, we look in row 2, and column 6, to get 5/18, as we did earlier.

Note that this is quite different from the chance of rolling a 2 after
a 6 (row 6, column 2) which is 2/15.

  - We now compute all length 6 tuples of the numbers 1 through
  6. There are 6^6 or 46656 of them, so I won't display them all. A
  sample tuple might look like this:

$\{3,5,6,5,3,1\}$

Note that these 46656 tuples *include* tuples with consecutive
duplicates like this:

$\{3,6,6,2,6,1\}$

but I will compensate for those cases below.

  - We now compute the probability of each possible tuple. To
  calculate the probability of:

$\{3,5,6,5,3,1\}$

for example, we proceed as follows:

    - The probability of the first roll being 3 is 0.15 (given)

    - To find the probability that the next roll will be 5, we look at
    row 3 column 5 in the table to find 5/17.

    - Similarly, to have a 6 follow the 5, 1/3

    - 5 following the 6, 1/3

    - 3 following the 5, 1/5

    - 1 following the 3, 1/17

Multiplying these, we get 1/17340.

The sum of this tuple is 3+5+6+5+3+1 or 23, so it's contribution to
the expected value is 23/17340.

  - What about tuples with consecutive duplicates like:

$\{3,6,6,2,6,1\}$

In the course of this calculation, we will find the probability of
transitioning from a 6 to a 6, which is 0. Thus, when we multiply the
probabilities together, we will get 0, and this tuple will contribute
nothing to the expected value as desired.

  - Finally, we sum the contributions to the expected value to get
  470474386324001/18866716141824.

*)

probs = Rationalize[{0.05, 0.1, 0.15, 0.2, 0.25, 0.25}];

values = {1,2,3,4,5,6};

(* The probabilitys that a number will be rolled and counted
immediately after n *)

follow[n_] := follow[n] = Module[{vals},

 (* set the probability of a repeat to 0 since we dont count those *)
 vals = probs;
 vals[[n]] = 0;
 vals = Table[vals[[i]] = vals[[i]]/(1-probs[[n]]), {i,1,6}];
 Return[vals];
];

(* simplify and perhaps create table *)

next[n_,m_] := next[n,m] = follow[n][[m]]

(* this just forces evaluation and let's me create a display table *)

display = Table[next[n,m],{n,1,6},{m,1,6}];

(* in order to display headers, we add 1-6 row and 1-6 column *)

(* TODO: re-assigning variables is actually bad practice; I'm also not
explaining the ugliness below since it's just for formatting purposes
*)

display = Prepend[display, Flatten[{"", values}]];

Table[display[[i+1]] = Prepend[display[[i+1]],i], {i,1,6}];

(* below directly from
https://reference.wolfram.com/language/howto/FormatATableOfData.html I
don't know what it means *)

Grid[display, Alignment -> Left, Spacings -> {2, 1}, Frame -> All, 
 ItemStyle -> "Text", Background -> {{Gray, None}, {LightGray, None}}]

(* The probability that a list of values will occur *)

plist[list_] := Module[{prob,next5},

 (* the first throw *)
 prob = probs[[list[[1]]]];

 (* the next five throws *)
 next5 = Product[next[list[[i]],list[[i+1]]],{i,1,5}];

 Return[prob*next5];
]
 
all = Tuples[values, 6];

Sum[plist[i]*Total[i],{i,all}]
