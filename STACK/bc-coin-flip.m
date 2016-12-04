(*

http://math.stackexchange.com/questions/6195/why-is-this-coin-flipping-probability-problem-unsolved/659670#659670

*)

(*

upto 2 flips:


H - stop with gain (50% chance)

TH - stop with 50% pull

TT - stop with 0% pull

if currently at k/n

1/2*(k+1)/(n+1) + 1/4*(k+2...... nope

in 3 flips what's the highest prob given k/n currently

HHH - 1
HHT - 1
HTH - 1
HTT - 1

TTT - 0
TTH - 1/3
THT - 1/2
THH - 2/3

1/2 + 1/8*1/3 + 1/8*1/2 + 1/8*2/3 (but no magic genie)

1/2*6/9 + 1/4*6/10 + 1/8*6/11 + 1/8*5/11


strat stop at first head or after 3 flips


H - 1/2 
TH - 1/4
TTH - 1/8
TTT - 1/8

1/2*1 + 1/4*1/2 + 1/8*1/3 + 1/8*0

1/2*6/9 + 1/4*7/10 + 1/8*7/11 + 1/8*6/11

1/2*(5+1)/(8+1) + 1/4*(5+1)/(8+2) + 1/8*(5+1)/(8+3)

Sum[1/2^n*6/(8+n), {n,1,Infinity}]

sum[n_] = Sum[1/2^k*6/(8+k), {k,1,n}]

(* with x/y as ratio *)

sum2[n_] = Sum[1/2^k*(x+1)/(y+k), {k,1,n}]

sum3[x_,y_] = Sum[1/2^k*(x+1)/(y+k), {k,1,Infinity}] - x/y

NOTE: this is only one strat

t = Flatten[Table[{x,y,sum3[x,y]},{y,1,10},{x,1,y}],1]

with genie:

HHH - 1, +3/+3
HHT - 1 +2/+2
HTH - 1 +1/+1 or +2/+3 (no +1/+1) [either will increase, but 1/1 is better]
HTT - 1 +1/+1

TTT - 0 dont throw
TTH - 1/3 dont throw
THT - 1/2 dont throw
THH - 2/3 +2/+3 

s0 = FullSimplify[1/8*((k+3)/(n+3) + (k+2)/(n+2) + (k+2)/(n+3) + (k+1)/(n+1) +
 k/n + k/n + k/n + (k+2)/(n+3)) - k/n, {Element[{n,k}, Integers], n>k, k>0}]

HTHH - 6/9 vs 8/12

HTHHH - 6/9 vs 9/13








I disagree with Haggstrom and Wastlund, partly because they have silly
characters in their name, but also because I need more downvotes.

Suppose you are 5/8, and decide to flip up to 3 more times, stopping
at the first head. What happens:

  - 1/2 the time you get a head right away, bringing your average to 6/9

  - 1/4 the time you get tail then head, bringing your average to 6/10

  - 1/8 the time you get tail, tail, head bringing your average to 6/11

  - 1/8 the time you get three tails, bringing your average to 5/11



Sum[







****** MORE HEADS = more money


At any point in the game, suppose you adopt the following strategy: I will flip until I get my first head (thus giving up possible additional gain), or after three tails. What are the possible outcomes:

  - First flip is head: 1/2 chance this occurs and my percentage for the three flips is 1.

  - First flip is tail, second flip is head: 1/4 chance this occurs and my percentage for the three flips is 1/2.

  - First two flips are tail, third flip is head: 1/8 chance this occurs and my average for the three flips is 1/3

  - All three flips are tail: 1/8 chance this occurs and my average of the three flips is 0.

The expected value of my percentage for the three flips is thus:

`1/2*1 + 1/4*1/2 + 1/8*1/3 + 1/8*0 = 2/3`

Since 2/3 is larger than 5/8, the expectation is that I will bring the average up.




*)
