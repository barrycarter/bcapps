(* Maximum daily change in planet separation as viewed from earth,
assuming circular orbits... for "production" use, at least double
these numbers *)

(* TODO: restore "FullSimplify" on each formula, but removing now
since I want to use production values *)

(* by plotting, maximal derv as function of p:

1.1: ~ 5.98
1.5: 4.9
2: 4.0
4: 2.1
5: 1.75
12: .66
50: .0143

In[50]:= ListPlot[{{1.5,4.9},{2,4},{4,2.1},{5,1.75},{12,.66},{50,.0143}}]       


*)

(* Assuming two dimensions; units are AU/years; using Keplers T^2=R^3 *)

conds = {Element[t,Reals],p>0,p1>0,p2>0,p1!=1,p2!=1,p!=1}
earth[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]}
plan[t_,p_] = {p^(3/2)*Cos[2*Pi*t/p],p^(3/2)*Sin[2*Pi*t/p]}
ang[t_,p_] = Apply[ArcTan,plan[t,p]-earth[t]]
anged[t_,p_] = D[ang[t,p],t]
angedd[t_,p_] = D[anged[t,p],t]

(* and now, for two separate planets *)

ang2[t_,p1_,p2_] = ang[t,p1]-ang[t,p2]
ang2ed[t_,p1_,p2_] = D[ang2[t,p1,p2],t]
ang2dd[t_,p1_,p2_] = D[ang2ed[t,p1,p2],t]

(* Periods:

Mars: 1.8808
Jupiter: 11.8618

*)


Solve[angedd[t,p]==0,t,Reals]

(* the second derv is 0 when t = p*n/(p-1) or t=(p+2p*n)/2/(p-1) *)

Simplify[anged[p*n/(p-1),p],Element[n,Integers]]
Simplify[anged[(p+2p*n)/2/(p-1),p],Element[n,Integers]]

(* min and max change in angle per year *)

2*Pi/(1+Sqrt[p]+p)
2*Pi/(1-Sqrt[p]+p)

(* computing for README.conjucts *)

op[p_] := AstronomicalData[p,"OrbitPeriod"]/
 AstronomicalData["Earth","OrbitPeriod"];

Table[{p,op[p],
2*Pi/(1+Sqrt[op[p]]+op[p])/365.2425/Degree,
2*Pi/(1-Sqrt[op[p]]+op[p])/365.2425/Degree},
{p,AstronomicalData["Planet"]}]




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

