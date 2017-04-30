(*

 http://politics.stackexchange.com/questions/15180/number-of-winning-coalitions-of-state-in-the-electoral-college?noredirect=1#comment54198_15180

It turns out the math here isn't difficult, but explaining the results can be.

As noted, if we treat DC as a state, we have 51 states. If we allow for Maine and Nebraska's vote splitting, we would have 57 states, since each state could theoretically vote for 3 different candidates. Quoting https://www.archives.gov/federal-register/electoral-college/faq.html

<blockquote>
It is possible for Candidate A to win the first district and receive one Electoral vote, Candidate B to win the second district and receive one Electoral vote, and Candidate C, who finished a close second in both the first and second districts, to win the two at-large Electoral votes. Although this is a possible scenario, it has not actually happened. 
</blockquote>

I ignore these states' split votes and also ignore faithless electors who could split any state's votes. With those assumptions:

*** TODO: determine number display format (plain, accounting and scientific?) and note in message and put below where I have N:

  - As expected there are N:$2^{51}$ total coalitions.

  - There is exactly one coalition with 538 electoral votes: namely, the coalition with all the states.

  - There is exactly one coalition with 0 electoral votes: namely, the coalition with no states.

  - There are no coalitions with only 1 or 2 electoral votes, since even the smalest state has 3 electoral votes.

  - For essentially the same reason as above, there no coalitions with exactly 536 or 537 electoral votes.

  - There are N:16976480564070 coalitions with 269 electoral votes, moreso than for any other number of votes. Note that these are tying coalitions that have exactly half the total number of electoral votes.

  - There are an equal number of winning coalitions and losing coalitions (the complement of a winning coalition is a losing coalition, so there's a 1-to-1 correspondance): N:1117411666560589 of each (that's N:2^51 minus the N:16976480564070 tying coalitions above)

  - The full list of how many coalitions there are for a given number of electoral votes is at ****TODO****, but here's a graph:

[[image39.gif]]

To answer the question, let's take California as a non-random example:

  - 
  

TODO: spellecheck





*)

(* this definition is necessary due to errors on brighton *)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {800, 600}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]


NumberForm[2^51, DigitBlock->3, NumberSeparator->","]

2,251,799,813,685,248

538 votes total

TODO: file with how many for each number

TODO: summary

TODO: faithless ignored

TODO: general problem up to 56

TODO: mention this file

TODO: math porn warning

<< /home/barrycarter/BCGIT/STACK/bc-elecvotes.m

(* this is absolutely hideous way to create polynomial *)

p0 = Expand[Times @@ (1+x^Transpose[elecvotes][[2]])]

t0 = Table[{i,Coefficient[p0, x,i]}, {i,0,538}]

ed = EmpiricalDistribution[Transpose[t0][[2]] -> Transpose[t0][[1]]];

mu = Mean[ed]
sd = StandardDeviation[ed]

pl0 = ListPlot[t0, Frame -> {True, True, False, False}, 
 FrameLabel -> {
 Text[Style["Electoral Votes", FontSize -> 20]],
 Text[Style["Coalitions", FontSize -> 20]]},
 PlotLabel -> "Number of Coalitions For Given Number of Electoral Votes"
]

pl1 = Plot[2^51*PDF[NormalDistribution[mu,sd]][x],{x,0,538}]

g0 = Graphics[{pl0, RGBColor[1,0,0], pl1}]

(* CA below *)

55 for CA

ca = Table[{i,
  Coefficient[PolynomialQuotientRemainder[p0, 1+x^55, x][[1]], x, i]},
 {i,0,538}]

Total[Transpose[Select[ca, #[[1]] >= 270 &]][[2]]]

293473506438925 winning coals wo CA

1117411666560589 total win coals

Total[Transpose[Select[ca, #[[1]] <= 268 &]][[2]]]

823938160121664 losing coals wo CA

1117411666560589 total lose coals

Total[Transpose[Select[ca, #[[1]] == 269 &]][[2]]]

8488240282035 ties wo CA

16976480564070 ties w CA

exactly 1/2 as expected

Total[Transpose[Select[ca, 215 <= #[[1]] <= 268 &]][[2]]]

521976413400704 = losing but winning w CA
823938160121664 = losing w/o CA

823938160121664 = winning w/ CA
293473506438925 = winning w/ CA



so 









Median[ed]

Mean[ed]-269


showit;


TODO: create table from t0

Sum[Coefficient[p0, x^i],{i,270,540}]

1117411666560589 total success coiltions (49.623% of all coals)

Clear[coals]
coals[i_] := coals[i] = 
 Sum[Coefficient[Expand[Times @@ (1+x^Transpose[Delete[elecvotes,i]][[2]])],
 x^j], {j,270-elecvotes[[i,2]],540}]


res = Table[{elecvotes[[i,1]], elecvotes[[i,2]], coals[i]}, 
 {i,1,Length[elecvotes]}]

Export["/tmp/elec.csv",res];

TODO: copy spreadsheet here

TODO: export TeX format

TODO: make sure gnumeric can handle bignums

TODO: infinite disclaimer

TODO: 38 states vs 12 states half pop

TODO: Same elect = same power (duh)

TODO: not really NP?
 


TODO: House, not Senate/amendment (but fun to see?)





Clear[num];
num[{}, 0] := 1
num[{}, n_] := 0
num[s_, n_] := num[s,n] = If[n<0, 0, Sum[
 num[Delete[s,i],n] + 
 If[n<s[[i]],0,num[Delete[s,i], n-s[[i]]]],{i,1,Length[s]}]/Length[s]]

(* below is as a module for convenience *)

Clear[num];

num[s_, n_] := num[s,n] = Module[{set2, sum1, sum2},

 (* remove numbers bigger than n, since no negatives *)
 set2 = Select[s, #<=n &];

 (* empty set *)
 If[Length[set2]==0, Return[If[n==0,1,0]]];

 (* immediate subsets that equal n *)
 sum1 = Sum[num[Delete[set2,i],n], {i,1,Length[set2]}];

 (* immediate subsets that equal n-i *)
 sum2 = Sum[num[Delete[set2,i],n-set2[[i]]], {i,1,Length[set2]}];

 Return[(sum1+sum2)/Length[set2]];
];



num[{1,2,3},6]


(* above works, below tests *)

t1024 = Table[i,{i,1,20}]

num[t1024, 15]

t1115 = Table[1+x^i,{i,1,20}]

t1117 = Product[(1+x^i),{i,1,50}]




num[{1,2,3},6]

num[{1,2},3]

num[{2}, 3] + num[{2}, 2] + num[{1}, 3] + num[{1}, 1]

num[{1,2,4,7}, 7]
?num



(* wrong approach above? *)

num[{1,2,4,7}, 7] = ...

{2,4,7} to 6 + {1,4,7} to 5 + {1,2,7} to 7 + {1,2,4} to 7









(* new method above here *)

a[1] = 1;
a[2] = 1;
a[3] = 1;
a[4] = 2;

a[n_] := a[n] = Sum[a[i]*a[n-i],{i,1,n/2}]

this approach wont work, counts states twice

TODO: not computed because google search

TODO: spreadsheet in CSV form or other form most can read, not gnumeric XML
