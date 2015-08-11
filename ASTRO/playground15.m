(* Maximum daily change in planet separation as viewed from earth,
assuming circular orbits... for "production" use, at least double
these numbers *)

(* Assuming two dimensions; units are AU and years; currently NOT
using Keplers identity T^2=R^3 *)

conds = {Element[{t,d1,p1,d2,p2},Reals], d1!=1, d2!=1, p1!=1, p2!=1}

earth[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]}
plan1[t_] = {d1*Cos[2*Pi*t/p1],d1*Sin[2*Pi*t/p1]}
plan2[t_] = {d2*Cos[2*Pi*t/p2],d2*Sin[2*Pi*t/p2]}


ange[t_] = ArcTan[(plan1[t]-earth[t])[[2]]/((plan1[t]-earth[t])[[1]])]
anged[t_] = Simplify[ange'[t],conds]
angedd[t_] = Simplify[ange''[t],conds]

conds = {Element[{t,d1,p1,d2,p2},Reals], d1>1, d2>1, p1>1, p2>1}

Solve[angedd[t]==0,t,Reals] /. conds

Solve[angedd[t]==0 && d1>1 && p1>1,t,Reals]



(* for outer planets first... *)

(* conds = {Element[{t,d1,p1,d2,p2},Reals], d1!=1, d2!=1, p1!=1, p2!=1} *)

conds = {Element[{t,d1,p1,d2,p2},Reals], d1>1, d2>1, p1>1, p2>1}

(* hardcoding since those are the results I ultimately need *)

(* Mars and Jupiter *)

d1 = 1.6660; p1 = 1.8808;

ange[t_] = Apply[ArcTan,plan1[t]-earth[t]]

Plot[ange[t],{t,0,100}]

Plot[ange'[t]/Degree/365.2425,{t,0,100}]

ange[t_] = Apply[ArcTan,plan1[t]-earth[t]]

ang[t_] = Simplify[VectorAngle[plan1[t]-earth[t],plan2[t]-earth[t]],conds]

angd[t_] = Simplify[ang'[t],conds]

angdd[t_] = Simplify[angd'[t],conds]

