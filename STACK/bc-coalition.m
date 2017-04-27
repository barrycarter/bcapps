(*

 http://politics.stackexchange.com/questions/15180/number-of-winning-coalitions-of-state-in-the-electoral-college?noredirect=1#comment54198_15180

It turns out the math here isn't difficult, but explaining the results can be.

As noted, if we treat DC as a state, we have 51 states. If we allow for Maine and Nebraska's vote splitting, we would have 57 states, since each state could theoretically vote for 3 different candidates. Quoting https://www.archives.gov/federal-register/electoral-college/faq.html

<blockquote>
It is possible for Candidate A to win the first district and receive one Electoral vote, Candidate B to win the second district and receive one Electoral vote, and Candidate C, who finished a close second in both the first and second districts, to win the two at-large Electoral votes. Although this is a possible scenario, it has not actually happened. 
</blockquote>

I ignore these states' split votes and also ignore faithless electors who could split any state's votes. With those assumptions:

  - As expected there are $2^{51}$ or 







*)

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
