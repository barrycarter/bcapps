(* playground for Mathematica *)

(* how much worse is linear interpolation for moonpos? *)

t = << /home/barrycarter/BCGIT/sample-data/manytables.txt

Flatten[t[[1,3,3,3]]]

(* the xyz vals from Hermite approx, for 2011 *)

hxval[r_] := t[[1,1,3]][r]
hyval[r_] := t[[1,2,3]][r]
hzval[r_] := t[[1,3,3]][r]

hdec[r_] := ArcSin[hzval[r]/Sqrt[hxval[r]^2+hyval[r]^2+hzval[r]^2]]/Degree

Plot[hdec[r],{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

(* and the domain, range for the x values of the moon *)

Flatten[t[[1,1,3,3]]]
Flatten[t[[1,1,3,4,3]]]

xm1 = Table[{t[[1,1,3,3,1,i]], t[[1,1,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
ym1 = Table[{t[[1,1,3,3,1,i]], t[[1,2,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
zm1 = Table[{t[[1,1,3,3,1,i]], t[[1,3,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]

flatx = Interpolation[xm1, InterpolationOrder -> 1]
flaty = Interpolation[ym1, InterpolationOrder -> 1]
flatz = Interpolation[zm1, InterpolationOrder -> 1]

flatdec[r_] := ArcSin[flatz[r]/Sqrt[flatx[r]^2+flaty[r]^2+flatz[r]^2]]/Degree

Plot[{flatx[r] - hxval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flaty[r] - hyval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatz[r] - hzval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

Plot[{flatdec[r],hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatdec[r]-hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]},
 PlotRange->All]

(* trivial difference, so could've just used linear *)


