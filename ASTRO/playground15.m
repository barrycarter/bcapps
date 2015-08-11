(* Maximum daily change in planet separation as viewed from earth,
assuming circular orbits... for "production" use, at least double
these numbers *)

(* Assuming two dimensions; units are AU and years; currently NOT
using Keplers identity T^2=R^3 *)

earth[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]}
plan1[t_] = {d1*Cos[2*Pi*t/p1],d1*Sin[2*Pi*t/p1]}
plan2[t_] = {d2*Cos[2*Pi*t/p2],d2*Sin[2*Pi*t/p2]}

conds = {Element[{t,d1,p1,d2,p2},Reals], d1!=1, d2!=1, p1!=1, p2!=1}

ange[t_] = Apply[ArcTan,plan1[t]-earth[t]]

ang[t_] = Simplify[VectorAngle[plan1[t]-earth[t],plan2[t]-earth[t]],conds]

angd[t_] = Simplify[ang'[t],conds]

angdd[t_] = Simplify[angd'[t],conds]




