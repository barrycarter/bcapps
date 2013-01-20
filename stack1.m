(* http://stackoverflow.com/questions/13977107 *)

showit := Module[{}, 
Export["/tmp/math.png",%, ImageSize->{800,600}]; Run["display /tmp/math.png&"]]

<</home/barrycarter/BCGIT/bclib.m

(* things I want simplified that mathematica doesnt simplify for some reason *)
simplify[Log[x_]/Log[y_]] := Log[y,x]
simplify[x_] := x
SetAttributes[simplify,Listable]

(* it turns out the symbolizing + * is not that useful after all *)
f[x_,y_] = x+y
fm[x_,y_] = x-y
g[x_,y_] = x*y
gd[x_,y_] = x/y
gd[x_,0] = Null

(* expand out h for "small" values *)
h[a_,b_] := a^b /; (Element[b,Reals] && Element[a,Reals] && 
 Element[Log[a],Reals] && b*Log[a]<10)

(* "unlog[x]" means 2^x but I dont want Mathematica to expand *)
(* using log base 2 since 2,4,8 all powers of two *)
(* h[a_,b_] = unlog[simplify[b*Log[2,a]]] *)

(* expand unlog if "small" *)
(* unlog[x_] := 2^x /; x<10 *)

(* all symbols for two numbers *)
allsyms[x_,y_] := allsyms[x,y] = 
 DeleteDuplicates[simplify[Flatten[{f[x,y], fm[x,y], fm[y,x], 
 g[x,y], gd[x,y], gd[y,x], h[x,y], h[y,x]}]]]

allsymops[s_,t_] := allsymops[s,t] = 
 DeleteDuplicates[Flatten[Outer[allsyms[#1,#2]&,s,t]]]

Clear[reach];
reach[{}] = {}
reach[{n_}] := reach[n] = {n}
reach[s_] := reach[s] = DeleteDuplicates[Flatten[
 Table[allsymops[reach[i],reach[Complement[s,i]]], 
  {i,Complement[Subsets[s],{ {},s}]}]]]

res = reach[{2,3,4,5,6}]
