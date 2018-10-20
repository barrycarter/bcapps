(*

http://math.stackexchange.com/questions/6195/why-is-this-coin-flipping-probability-problem-unsolved/659670#659670

*)


(*

20181019.151811 approach: next states if < 5/8

*)

nState[{p_, q_, n_}] := If[p/q >= 5/8, {}, {{p+1,q+1,n+1}, {p,q+1,n+1}}];

Flatten[Map[nState,Flatten[Map[nState, nState[{5,9,1}]],1]],1]

(* chance of being in state p, q *)

f[5, 8] = 1;
f[p_, 8] = 0;

f[p_, q_] := f[p,q] = If[p/(q-1) > 5/8, 0, f[p, q-1]]/2 +
                      If[(p-1)/(q-1) > 5/8, 0, f[p-1, q-1]]/2

Table[f[p, 10], {p, Ceiling[10*5/8], 10}]

probs[q_] := Table[f[p, q], {p, Floor[q*5/8+1], q}]

wins[q_] := Table[f[p, q]*p/q, {p, Floor[q*5/8+1], q}]

Table[Total[probs[n]], {n,9,20}]

shows more than 100%

temp1628 = Table[Total[wins[n]], {n, 9, 100}]

temp1629 = Flatten[Position[temp1628, _?(# > 0 &)]]

A047400	   Numbers that are congruent to {1, 3, 6} mod 8

when mod 1, just 1 entry

same when mod 3

same when mod 6

probs[9+8][[1]]/probs[9][[1]]

temp1640 = Table[probs[9+8*i][[1]]/probs[1+8*i][[1]], {i, 1, 50}]

temp1644 = Table[Total[probs[9+8*i]], {i, 0, 100}]

Log[Take[Denominator[temp1644],10]]/Log[2]

{1., 9., 17., 22., 32., 41., 49., 57., 65., 73.}

Out[191]= {1., 9., 17., 22., 32., 41., 49., 57., 65., 73., 81., 89., 93., 105., 
 
>    111., 120., 129., 137., 145., 153., 161., 169., 172., 184., 193., 200., 
 
>    208., 212., 225., 232., 241., 249., 256., 262., 272., 281., 289., 297., 
 
>    305., 313., 321., 328., 335., 345., 353., 361., 369., 377., 385., 393., 
 
>    401., 407., 414., 424., 430., 439., 447., 457., 464., 473., 481., 489., 
 
>    495., 505., 511., 520., 529., 537., 544., 553., 556., 568., 576., 585., 
 
>    591., 599., 609., 616., 624., 632., 640., 644., 655., 665., 673., 680., 
 
>    689., 696., 705., 711., 721., 729., 737., 745., 753., 761., 767., 774., 
 
>    785., 793.}



temp1647 = Table[Total[wins[9+8*i]], {i, 0, 100}]

temp1648 = Table[Total[wins[11+8*i]], {i, 0, 100}]

temp1649 = Table[Total[wins[14+8*i]], {i, 0, 100}]


ListLogPlot[{temp1647, temp1648, temp1649}]

ListLogPlot[{temp1647+temp1648+temp1649}]

temp1650 = Table[Total[wins[i]], {i, 9, 100}]

temp1651 = Table[{i, Total[wins[i]]}, {i, 9, 1000}]

temp1652 = Select[temp1651, #[[2]] > 0 &];

temp1653 = Table[{i[[1]], Log[i[[2]]]}, {i, temp1652}]

Fit[temp1653, {1,x}, x]

-7.28864 - 0.0361529 x

In[173]:= Sum[%, {x,9,Infinity}]                                                

Out[173]= 0.0138983






 




(*

UPTO 2 flips:


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

is better to flip three more



s0 = FullSimplify[1/8*((k+3)/(n+3) + (k+2)/(n+2) + (k+2)/(n+3) + (k+1)/(n+1) +
 k/n + k/n + k/n + (k+2)/(n+3)) - k/n, {Element[{n,k}, Integers], n>k, k>0}]

HTHH - 6/9 vs 8/12

HTHHH - 6/9 vs 9/13



I believe the confusion occurs because the problem is not well-defined.

Suppose you are 5/8, and decide to flip up to 3 more times, stopping
at the first head. What happens:

  - 1/2 the time you get a head right away, bringing your average to 6/9

  - 1/4 the time you get tail then head, bringing your average to 6/10

  - 1/8 the time you get tail, tail, head bringing your average to 6/11

  - 1/8 the time you get three tails, bringing your average to 5/11

******AVERAGE ABOVE

Now, suppose you were clairvoyant and knew how your next three flips
would turn out (but couldn't control them, just know them in advance),
if you chose to make them:

  - If you knew you'd flip 3 heads in a row (1/8th chance that happens), you'd take all three flips and bring your average to 




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


a[k_, n_] = ((k+1)/(n+1) + k/(n+1))/2

list = {1, 1, 0, 1, 0, 1, 1}

maxavg[list_, k_, n_] := Module[{tot, i, max, index},

 For[i=1; tot=k; max=k/n, i<=Length[list], i++,
  tot = tot + list[[i]];
  avg = tot/(i+n);
  If[avg > max, max=avg; index = i]
 ];

 Return[{max, index}];

]
 
t1904 = Tuples[{0,1}, 10];

t1905 = Table[maxavg[i, 5, 8][[1]], {i, t1904}]

average is 0.669782

t1906 = Table[maxavg[i, 5, 8][[1]], {i, Tuples[{0,1},3]}]

for 10 rolls

0.669782 is mean
0.00194208 is variance, SD is 0.044069

t1906 = Table[maxavg[i, 5, 8][[1]], {i, Tuples[{0,1},10]}]
Histogram[t1906, {.05}]

t1906 = Table[maxavg[i, 5, 8][[1]], {i, Tuples[{0,1},5]}]
Histogram[t1906, {.05}]

bins are 14, 10, 6, 2 for 5% for 5 rolls

bins are 28, 18, 15, 4 for 5% for 6 rolls (so, not great)

7, 5, 3, 1 for 4 rolls (60-65, 65-70, 70-75, 75-80)

one more roll: mean 31/48 = 0.645833

two more: 0.654167

meanmore[n_] := Mean[Table[maxavg[i, 5, 8][[1]], {i, Tuples[{0,1},n]}]]

Table[meanmore[n],{n,1,14}]

Table[maxavg[i,6,9][[1]], {i, Tuples[{0,1},1]}]

Table[maxavg[i,5,9][[1]], {i, Tuples[{0,1},1]}]

meanonemore[n_] := 
 (Mean[Table[maxavg[i,6,9][[1]], {i, Tuples[{0,1},n]}]] +
 Mean[Table[maxavg[i,5,9][[1]], {i, Tuples[{0,1},n]}]])/2

Table[maxavg[i, 5, 9][[1]], {i, Tuples[{0,1},10]}]






PDF[HalfNormalDistribution[1]][x]

*)
