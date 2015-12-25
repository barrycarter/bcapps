(* http://astronomy.stackexchange.com/questions/12981/delta-v-from-mercury-surface-to-venus-surface *)

m = -(6.672*10^-11) (7*10^17) ;
st = {{1000, 1000, 1000, 0, -100, 0},
      {500, -1000, -1000, -110, 100, 0},
      {0, 100, 500, 350, -100, 0}};

r = {x @ t, y @ t, z @ t};

o[n_] := NDSolve[Join[{Equal @@ Join[(D[r, {t, 2}]/r), {m/Norm @
r^3}]}, Thread[{x[0], y[0], z[0], x'[0], y'[0], z'[0]} == st[[n]]]],
r, {t, 0, 1000}]

d = {d1, d2, d3} = Evaluate[r /. o /@ {1, 2, 3}];

Animate[Show[{ ParametricPlot3D[d /. t -> u, {u, 0, a},
PlotRange->1600 {{-1, 1}, {-1, 1}, {-1, 1}}], Graphics3D[
MapThread[{#1, Sphere[#2 /. t -> a, #3]} &, {{Yellow, Green, Blue,
Purple}, {{0, 0, 0}, d1, d2, d3}, 50 {2, 1, 1, 1}}]]}], {a, 0, 100,
0.1}]
