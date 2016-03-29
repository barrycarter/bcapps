(*

http://mathematica.stackexchange.com/questions/111255/toms-family-how-to-cross-the-bridge

As @dr-belisarius notes, there may be no easy way to solve this with
graphs. So let's try a hard way.

I define a state $S$ as the set of people on the left ("wrong") side
of the bridge. There are 32 possible states, although I don't think
all of them are reachable. The initial state is `{t, b, f, m, g}` and
the "winning" state is `{}`.

Given a state $i$, I define a "trip" as follows:

  - $j$, a subset of one or two people from $i$ who cross the bridge
  (left to right) with the flashlight. This is `j = Subsets[i,{1,2}]`

  - $k$, a set of one or two people who cross the bridge (right to
  left) to return the flashlight. The 1 or 2 people who cross back are
  some subset of:

    - the ones who just crossed over (ie, $j$) *or*

    - the ones already on the other side (ie, the complement of $i$)

I believe the second condition is crucial to solving the problem. Note
that if 2 people cross back, they need not be both from $j$ or both
from the complement of $i$. 

Thus, this is `k = Subsets[Union[Complement[people, i],j], {1,2}]`

Note that my definition of "trip" assumes the flashlight will always
be returned, even if everybody is safely on the right side of the
bridge. I will correct for this later.

For now, let's enumerate all trips, by looping through all values of
i, j, and k above. For convenience, we'll also record the state after
the trip is complete, which is:

`Union[Complement[i, j], k]`

<pre><code>
(* some setup; we won't use 'times' or 'f' now, but will need them later *)
people = {"t", "b", "f", "m", "g"};
times = {1, 3, 6, 8, 12};
Table[f[people[[i]]] = times[[i]], {i,1,Length[people]}];
states = Subsets[people];

allTrips = Flatten[Table[{i,j,k, Union[Complement[i, j], k]}, 
 {i, states}, {j, Subsets[i,{1,2}]}, 
 {k, Subsets[Union[Complement[people, i],j], {1,2}]}
],2];

</pre></code>

Note that `Length[allTrips]` is 1180.

To build a graph, we now connect initial and final states, and compute
the edge length. This is fairly straightforward: we take the max of
the left-to-right crossers time plus max of the right-to-left crossers
time, with one exception: if the left-to-right crossing leaves no one
on the left side, we ignore the right-to-left crossing. This special
case changes both the length of the trip and the final state.

<pre><code>

edges = Table[{i[[1]], If[Sort[i[[2]]] == Sort[i[[1]]], {}, i[[4]]],
 Max[Map[f,i[[1]]]]+If[Sort[i[[2]]] == Sort[i[[1]]], 0, Max[Map[f, i[[4]]]]]},
{i, allTrips}];

</code></pre>

edges2 = DeleteDuplicates[Table[StringJoin[Sort[i[[1]]]]<>"x" <->
StringJoin[Sort[i[[2]]]]<>"x", {i,edges}]]



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

  - The time it takes $T$ to cross

  - Whether $S = T$ (ie, whether this trip is a final/winning trip)

  - The set of 1 or 2 people who return the flashlight.

  - The time it takes the set above to cross.

  - The ending state after the flashlight is returned.

Note that I don't include the total time, because if $S = T$ there's a
special case.

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
trips[state_, pair_] := trips[state, pair] = Module[{returners}, 

 (* subsets that can return the flashlight *)
 returners = Subsets[DeleteDuplicates[
 Union[Complement[people, state], pair]], {1,2}];

 (* for each such subset i in returners *)
 Return[Table[{state, pair, Max[Map[f,pair]], Sort[state] == Sort[pair], i, 
 Max[Map[f,i]], Union[Complement[state, pair], i]}, {i, returners}]];
]

</code></pre>

To find all possible trips, we simply loop carefully (to avoid
nesting) over all states and all pairs for a given state.

<pre><code>

allTrips = Flatten[Table[
 Flatten[Table[trips[state, i], {i, Subsets[state, {1,2}]}],1],
 {state,states}], 1];

</pre></code>

There are 1180 possible trips. We now assign lengths to each of these
trips. This is fairly straightforward:

  - If the left side is empty after the left-to-right trip, the length
  is the length of the left-to-right crossing.

  - 

TODO: request golf

TODO: note lazy/bad, not educational

trips2[state_] := Flatten[Table[trips[state, i], {i, Subsets[state, {1,2}]}],1]

test0717 = trips2[states[[19]]]

test0723 = Flatten[Table[trips2[state], {state,states}],1];

TODO: note PDF... inefficient





<h>torch = flashlight</h>

TODO: except at last state, having 1 person go across doesnt work, but
it doesnt work anyway because he couldnt possibly have torch

trips[state_] := Module[{pairs, ret},
 pairs = Subsets[state,{2}];
 ret = Table[{{i,i[[1]]}, {i,i[[2]]}}, {i,pairs}];
 Return[ret];
]





