(* Continuous Fourier transforms to approximate data such as
solar/lunar positions *)

(* given a collection of data, return the cosine-ish function that
approximates it. From
http://stackoverflow.com/questions/4463481/continuous-fourier-transform-on-discrete-data-using-mathematica
*)

(* TODO: dislike returning f[x] instead of a pure function f, but
can't find fix for now *)

(* tmp isn't mirrored so this data [obtained from
http://ssd.jpl.nasa.gov/?horizons] isn't available in this repo [but
will be if I find it more useful] *)

data = ReadList["/home/barrycarter/BCGIT/tmp/moondec.txt"]

data = Table[43.2316 + 43.9356*Cos[81.7904*x/1000 - 1.59204], {x,1,1000}]

superfourier[data]

(* defining h1 to be 0 is silly, but useful; h2 is effectively
superfourier on the data *)

h[0] = 0 &

h[n_] := h[n] = refine[data,h[n-1]]

t[n_] := Table[h[n][x], {x,1,Length[data]}]

ListPlot[data-t[0]]
ListPlot[data-t[1]]
ListPlot[data-t[2]]
(* 1.5 deg error below *)
ListPlot[data-t[3]]
(* upto 1.0 deg error below *)
ListPlot[data-t[5]]
(* 0.5 below *)
ListPlot[data-t[7]]
ListPlot[data-t[11]]
ListPlot[data-t[15]]
ListPlot[data-t[25]]


showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

normalized = (data-Mean[data])/Max[Abs[data]]

acn = ArcCos[normalized]

