(* Attempt to solve http://math.stackexchange.com/questions/1615460/expected-value-and-a-variance-of-a-die-sequence  in general *)

(* TODO: Sum of p[i] is 1 *)

probs = Table[p[i],{i,1,6}]

conds = Flatten[{Table[{p[i]>0, p[i]<1},{i,1,6}], Total[probs] == 1}]

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

(* The probability that a list of values will occur *)

plist[list_] := Module[{prob,nextfew},

 (* the first throw *)
 prob = probs[[list[[1]]]];

 (* the next five throws *)
 nextfew = Product[next[list[[i]],list[[i+1]]],{i,1,Length[list]-1}];

 Return[prob*nextfew];
]
 
sum[n_] := Sum[plist[i]*Total[i],{i,Tuples[values,n]}];

(* FullSimplify[sum, conds] * )



