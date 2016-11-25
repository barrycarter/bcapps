(* http://math.stackexchange.com/questions/2028308/how-to-determine-the-average-number-of-dice-showing-the-most-common-value *)

(*

This problem appears to be very difficult for even small numbers and I
suspect you are a sadistic math professor :)

I've modified the problem slightly to count the number of "rolls" that
will have a given mode.

For k=2 (ie, flipping a coin), the mode is distributed as follows:

If[m<k, 0, 2*Binomial[n,k]]

TODO: prettify above

for google searching, try just numbers no commas

151200 691200 144900 12150 540 10

6d10 is {151200, 691200, 144900, 12150, 540, 10}

as b222208

1000 151200
2040 691200
6358 144900
676 12150

as b269838

2973 151200
5878 691200
8661 144900
861 12150

counts[10,3] as normal

expect each number to show up 3.33333 times

with sd of Sqrt[10*1/3*2/3] = 1.49071 ish

CDF[NormalDistribution[10/3, Sqrt[20/9]]][4.5]-
CDF[NormalDistribution[10/3, Sqrt[20/9]]][3.5]

CDF[NormalDistribution[10/3, Sqrt[20/9]]][5.5]-
CDF[NormalDistribution[10/3, Sqrt[20/9]]][4.5]

CDF[NormalDistribution[10/3, Sqrt[20/9]]][3.5]

(that's like half the curve)

counts[6, 6] = {720, 28800, 14700, 2250, 180, 6}

1 is mean, 6*1/6*5/6 = 5/6 var, so 0.912871 is SD

counts[9, 4] = {0, 0, 97440, 113400, 40824, 9072, 1296, 108, 4}

9/4 is mean n/k in general

variance is n*(1/k)*(1-1/k)

dist[n_,k_] = NormalDistribution[n/k, Sqrt[n*(1/k)*(1-1/k)]]

CDF[dist[9,4]][9/4] = 1/2

TODO: (note how the doubling corresponds to the case k=2 )

Plot[2*PDF[dist[9,4]][x], {x,9/4,9}, AxesOrigin -> {0,0}, PlotRange -> All]

t1 = Table[PDF[dist[9,4]][i], {i,3,9}]

t2 = t1/Total[t1]

prob that at least one of 9 number reached 4?

1-CDF[dist[9,4]][3.5]












(* rolling 8d6 = 1679616 *)

<<Combinatorica`

(* below is {n}d{k} *)

(* TODO: this isn't correct, because it ignores n > k having 0s *)

counts[n_, k_] := counts[n,k] = 
 BinCounts[Map[Max[BinCounts[#]]&, Tuples[Range[1,k],n]], {1,n+1,1}];

(* just to compute them *)

t = Table[{i,j,counts[i,j]},{i,2,6},{j,2,6}];

ListPlot[counts[5,6], PlotJoined -> True, PlotRange -> All]
showit

t0111 = Table[counts[6,i]/i^6,{i,2,6}]

ListPlot[t0111, PlotJoined -> True, PlotRange -> All]
showit


(* 

results for d6:

2 = {30,6}

3 = {120, 90, 6}

4 = {360, 810, 120, 6}

5 = {720, 5400, 1500, 150, 6}

6 = {720, 28800, 14700, 2250, 180, 6}

7 = {0, 128520, 121800, 26250, 3150, 210, 6}

ListPlot[{360, 810, 120, 6}, PlotJoined -> True]

guesstimate from normal:

1/6 is the mean and Sqrt[n*1/6*5/6] is the SD

for 4d6:

https://oeis.org/A139813 as triangle array gives for 2?

https://oeis.org/A140818

https://oeis.org/A028330

Plot[PDF[NormalDistribution[6^4/6, Sqrt[4*1/6*5/6]]][x], {x,1,6^3}]


count[10,2] 

count[11,2] is elements 30 thru 35 in https://oeis.org/A028330

count[12,2] 2nd to last elts are 36-41

for [n,2] it appears to be the right half of the triangular form of https://oeis.org/A139813


