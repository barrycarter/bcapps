(*

http://mathematica.stackexchange.com/questions/111371/plots-of-united-states-states-with-non-standard-labels

I don't have Mathematica 10, so I used the KML file
http://code.google.com/apis/kml/documentation/us_states.kml

The only real improvement I made is modifying the text font size based
on the state's width. This doesn't work 100%, since Mathematica
doesn't use a monospaced font, but most of the "names" now fit
approximately into their states.

Other things I did that aren't really improvements:

  - Omitted Hawaii and Alaska (no insets), since they drastically
  reduce the space available for the continental United States (no
  extra credit for me).

  - Used an equiangular projection, which works OK for the continental
  United States.

  - Replaced the names of the 50 states with the list of words that
  sound rude but aren't:
  http://mentalfloss.com/article/58036/50-words-sound-rude-actually-arent

My code:

<pre><code>
(* list of "names" is in this file *)

<<"/home/barrycarter/BCGIT/STACK/badwords.m";

(* I downloaded a local copy of http://code.google.com/apis/kml/documentation/us_states.kml but could've also imported it as http *)

usa = Import["/home/barrycarter/BCGIT/STACK/us_states.kml", "Data"];

(* helper functions *)
state[n_] := usa[[1,2,2,n]]
name[n_] := usa[[1,6,2,n]]
centroid[n_] := Flatten[Apply[List,state[n][[1]]]]
ewpoints[n_] := Transpose[Partition[Flatten[Apply[List,state[n],1]],2]]
width[n_] := Max[ewpoints[n][[1]]]-Min[ewpoints[n][[1]]]

(* omitting Alaska and Hawaii; cheating because I looked up their numbers, instead of omitting them "properly" *)
states = Table[i, {i,Flatten[{1,Range[3,10],Range[12,50]}]}];

(* note the fontsize is tied to the ImageSize in the later Export *)
g = Table[{
 EdgeForm[Thin],
 Text[Style[f[i], FontSize-> 60*width[i]/StringLength[f[i]]], centroid[i]],
 Opacity[0.1],
 state[i]
}, {i,states}];

Show[Graphics[g], AspectRatio -> 1/1.5]
Export["/tmp/test.gif", %, ImageSize -> {1024*3,768*3}]
</code></pre>

The result:

[[/tmp/test.gif]]

Git: https://github.com/barrycarter/bcapps/blob/master/STACK/bc-state-names.m
