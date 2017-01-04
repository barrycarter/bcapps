(*

math -initfile ~/BCGIT/ASTRO/bc-astro-formulas.m

http://astronomy.stackexchange.com/questions/19619/how-to-make-motion-of-the-sun-more-apparent-at-seconds-scale

TODO: note when setting, asymptotic to infinity

TODO: note ra/dec fixed is reasonable

TODO: link to formulas

TODO: sid day length and fixed ra cancel each other out

decHaLat2azEl[dec,ha,lat]

decHaLat2azEl[dec,0,lat]

conds = {Element[{dec,ha,lat}, Reals]}
D[decHaLat2azEl[dec,ha,lat],ha]

FullSimplify[% /. ha -> 0]

{-(Cos[dec] Csc[dec - lat]), 0}

Solve[D[-Cos[dec]*Csc[dec-lat],dec]==0, dec]

decHaLat2azEl[dec,ha,lat]

decHaLat2azEl[0,ha,35*Degree]

ParametricPlot[decHaLat2azEl[0,ha,35*Degree], {ha,-Pi,Pi}]

ParametricPlot[decHaLat2azEl[0,ha,35*Degree]/Degree, {ha,-Pi,Pi}]

TODO: actually list parametric plot so we can see distances and stuff

helper function below makes az range 0-360 because we want center

(* fix[pair_] := {pair[[1]]+2*Pi, pair[[2]]} *)

t = Table[N[decHaLat2azEl[0,ha,35*Degree]]/Degree,{ha,-Pi,Pi,2*Pi/48}]
ListPlot[t]
showit




*)

