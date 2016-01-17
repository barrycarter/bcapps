(* Attempt to solve http://math.stackexchange.com/questions/1615460/expected-value-and-a-variance-of-a-die-sequence *)

probs = Rationalize[{0.05, 0.1, 0.15, 0.2, 0.25, 0.25}];

values = {1,2,3,4,5,6};

e1 = Sum[values[[i]]*probs[[i]],{i,1,6}]

(* If the previous roll was 'n', probabilities for the next roll are... *)

ps[n_] := Drop[probs,{n}]/(1-probs[[n]]);

(* The values are: *)

vals[n_] := Drop[values,{n}];

(* and the expected value is *)

e[n_] := Sum[values[[i]]*ps[n][[i]],{i,1,5}]





(* if we got a 1 the first time, the probs are: *)

probs = Drop[ps,{1}]/(1-ps[[1]])

(* possible values are: *)

values = Drop[{1,2,3,4,5,6},{1}];

(* the expected value is: *)

Sum[probs[[i]]*values[[i]], {i,5}]

(* and the chance we rolled 1 first is *)



