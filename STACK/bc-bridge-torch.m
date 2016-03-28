(*

http://mathematica.stackexchange.com/questions/111255/toms-family-how-to-cross-the-bridge

As @dr-belisarius notes, there may be no easy way to solve this with
graphs. So let's try a hard way.

I define a state $S$ as the set of people on the left ("wrong") side
of the bridge. There are 32 possible states, although I don't think
all of them are reachable. The initial state is `{t, b, f, m, g}` and
the winning state is `{}`.

Given a state $S$, I define a "trip" as follows:

  - One or two people from $S$ cross the bridge (left to right) with
  the flashlight.

    - If this results in $S$ being empty, we have a special case since
    we've won.

  - One or two people cross the bridge (right to left) to return the
  flashlight. The people who cross back are either the ones who
  crossed over *or* people who crossed over to the right side in an
  earlier trip. I believe this *or* condition is critical to solving
  the problem(?)

Given an initial state $S$ and one or two members of that subset
(called set $T$), the following module returns all possible trips
where $T$ are the ones to cross left to right. Each "trip" is returned
as a list of the following:

  - The initial state $S$ itself.

  - The set $T$ of left-to-right crossers.

  - Whether $S = T$ (ie, whether this trip is a final/winning trip)

  - The set of 1 or 2 people who return the flashlight.

  - The ending state after the flashlight is returned

  - The total bidrectional time for the trip.

This is actually a helper function for "educational" purposes. In
theory, we could compute the trips for all pairs of a given state, and
even for all possible states, in a single function/module.

<pre><code>

(* some setup *)
people = {"t", "b", "f", "m", "g"};
times = {1, 3, 6, 8, 12};
Table[f[people[[i]]] = times[[i]], {i,1,Length[people]}];
states = Subsets[people];

(* note that "pair" can be just one person *)
trips[state_, pair_] := Module[{returners}, 

 Return[{state, pair, Complement[state,pair]}];

 (* subsets that can return the flashlight *)
 returners = Subsets[DeleteDuplicates[
 Union[Complement[people, state], pair]], {1,2}];

 (* for each such subset i in returners *)
 Return[Table[{state, pair, "ignore", i, 
 Complement[state, pair],
 Union[Complement[state, pair], i], 
 Max[Map[f, pair]] + Max[Map[f,i]]}, {i, returners}]];
]

</code></pre>






<h>torch = flashlight</h>

TODO: except at last state, having 1 person go across doesnt work, but
it doesnt work anyway because he couldnt possibly have torch

trips[state_] := Module[{pairs, ret},
 pairs = Subsets[state,{2}];
 ret = Table[{{i,i[[1]]}, {i,i[[2]]}}, {i,pairs}];
 Return[ret];
]





