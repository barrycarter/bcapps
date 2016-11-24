(* http://math.stackexchange.com/questions/2028308/how-to-determine-the-average-number-of-dice-showing-the-most-common-value *)

(* rolling 8d6 = 1679616 *)

<<Combinatorica`

d = Range[1,4]

x = Tuples[d,7];

counts = Table[Max[BinCounts[i]], {i, x}];

BinCounts[counts]

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

for 4d6

Plot[PDF[NormalDistribution[6^4/6, Sqrt[4*1/6*5/6]]][x], {x,1,6^3}]

results for d4:



7d4 = {0, 2520, 9240, 3780, 756, 84, 4}

