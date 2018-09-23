(*

figuring out mathematica's linear interpolation

*)

f[-1][1] = a 
f[0][1] = b
f[1][1] = c
f[-1][0] = d
f[0][0] = e
f[1][0] = f
f[-1][-1] = g
f[0][-1] = h
f[1][-1] = i

g = Interpolation[f, InterpolationOrder -> 1]

Interpolation::innd: 
   First argument in f does not contain a list of data and coordinates.

Clear[f]
f[-1][1] = 1
f[0][1] = 2
f[1][1] = 3
f[-1][0] = 4
f[0][0] = 5
f[1][0] = 6
f[-1][-1] = 7
f[0][-1] = 8
f[1][-1] = 9

g = Interpolation[f, InterpolationOrder -> 1]

woops

atab = Table[a[i][j], {i,-1,1}, {j,-1,1}]

g = Interpolation[atab, InterpolationOrder -> 1]

Interpolation::indat: 
   Data point {a[-1][-1], a[-1][0], a[-1][1]} contains abscissa a[-1][-1]
    , which is not a real number.

btab = Table[{i,j,i*3 + j}, {i,-1,1}, {j,-1,1}]

g = Interpolation[Flatten[btab,1], InterpolationOrder -> 1]

ContourPlot[g[x,y], {x,-1,1}, {y,-1,1}, PlotLegends -> True, Axes -> True,
 GridLines -> True]

ContourPlot[g[x,y], {x,-1,1}, {y,-1,1}, PlotLegends -> True, Axes -> True,
 GridLines -> True, Contours -> 16, ColorFunction -> Hue]

ContourPlot[g[x,y], {x,-2,2}, {y,-2,2}, PlotLegends -> True, Axes -> True,
 GridLines -> True]

g[0,0]

ctab = Table[{i,j, RandomReal[]}, {i,-1,1}, {j,-1,1}]

g = Interpolation[Flatten[ctab,1], InterpolationOrder -> 1]

ContourPlot[g[x,y], {x,-1,1}, {y,-1,1}, PlotLegends -> True, Axes -> True,
 GridLines -> True, Contours -> 16, ColorFunction -> Hue]

dtab = Table[{i,j, RandomReal[]}, {i,-5,5}, {j,-5,5}]

g = Interpolation[Flatten[dtab,1], InterpolationOrder -> 1]

ContourPlot[g[x,y], {x,-5,5}, {y,-5,5}, PlotLegends -> True, Axes -> True,
 GridLines -> True, Contours -> 16, ColorFunction -> Hue]

ContourPlot[g[x,y], {x,-5,5}, {y,-5,5}, PlotLegends -> True, Axes ->
True, GridLines -> True, Contours -> 64, ColorFunction -> Hue,
ContourLines -> False]

<question>

Subject: Find region of given value for linear Interpolation function

Summary: How do I find the (possibly disconnected) region(s) where a linear interpolating function is between two specified values?

Example:

<pre><code>

(* this creates a 10x10 grid of random real numbers and a function to
linearly interpolate them *)

rand = Table[{i, j, RandomReal[]}, {i, 1, 10}, {j, 1, 10}];

f = Interpolation[Flatten[rand,1], InterpolationOrder -> 1]

(*

I want the region(s) where f is between 0.5 and 0.7, for example.

If it's not easy to find the regions, I'd like to get the area of
where the function is between those two values.

However, because I plan to treat the region in a non-Euclidean way, I
actually need the region more than I need the area

*)
</code></pre>

Goal: I have the "distance from coastline" data for a grid of latitude/longitude points. I want to find the total area where the distance from coastline rounds to, say, 492km (ie, is between 491.5km and 492.5km). Since I only have data for a finite number of points, I'm interpolating to find values for all points. I realize this interpolation is inaccurate, potentially very inaccurate. I'm OK with treating the Earth as a sphere even though it's actually an ellipsoid.






WHY INTERPOLT









