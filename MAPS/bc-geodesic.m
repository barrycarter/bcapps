<formulas>

conds = {
 -Pi <= theta1 <= Pi, -Pi <= theta2 <= Pi, -Pi <= theta3 <= Pi,
 -Pi/2 <= phi1 <= Pi/2, -Pi/2 <= phi2 <= Pi/2, -Pi/2 <= phi3 <= Pi/2,
 t > 0, t < 1
};

(* these do not always apply *)

simps = {ArcTan[y_, x_] -> ArcTan[x/y]}

fullmat = 

{{Cos[phi1]*Cos[theta1], Cos[phi1]*Sin[theta1], Sin[phi1]}, 
 {(-Sin[theta1] + Cos[theta1]*Sin[phi1]*(-(Cot[theta1 - theta2]*Sin[phi1]) + 
      Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]))/
   Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
        Tan[phi2])^2], (Cos[theta1] + Sin[phi1]*Sin[theta1]*
     (-(Cot[theta1 - theta2]*Sin[phi1]) + Cos[phi1]*Csc[theta1 - theta2]*
       Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2], 
  (Cos[phi1]*(Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
      Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]}, 
 {(Csc[theta1 - theta2]*(Sin[phi1]*Sin[theta2] - Cos[phi1]*Sin[theta1]*
      Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2], 
  (Csc[theta1 - theta2]*(-(Cos[theta2]*Sin[phi1]) + Cos[phi1]*Cos[theta1]*
      Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2], 
  Cos[phi1]/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]}}

invfullmat = Inverse[fullmat]

</formulas>

temp1343 = FullSimplify[sph2xyz[theta3, phi3, 1], conds]

temp1344 = Simplify[fullmat.temp1343, conds]

temp1345 = Simplify[xyz2sph[temp1344], conds]

Simplify[temp1345[[1]], conds]

Simplify[temp1345[[2]], conds]

newLng[theta1_, phi1_, theta2_, phi2_, theta3_, phi3_] =

ArcTan[Cos[phi1]*Cos[phi3]*Cos[theta1 - theta3] + Sin[phi1]*Sin[phi3], 
 (Cos[phi1]*Sin[phi3]*(Cot[theta1 - theta2]*Sin[phi1] - 
     Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]) + 
   Cos[phi3]*(-(Sin[theta1]*(Cos[theta3] + Sin[phi1]*Sin[theta3]*
         (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
           Tan[phi2]))) + Cos[theta1]*(Sin[theta3] + Cos[theta3]*Sin[phi1]*
        (-(Cot[theta1 - theta2]*Sin[phi1]) + Cos[phi1]*Csc[theta1 - theta2]*
          Tan[phi2]))))/
  Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
       Tan[phi2])^2]]

newLat[theta1_, phi1_, theta2_, phi2_, theta3_, phi3_] =

ArcTan[Sqrt[(Cos[phi1]*Cos[phi3]*Cos[theta1 - theta3] + Sin[phi1]*Sin[phi3])^
    2 + (Cos[phi1]*Sin[phi3]*(Cot[theta1 - theta2]*Sin[phi1] - 
        Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]) + 
      Cos[phi3]*(-(Sin[theta1]*(Cos[theta3] + Sin[phi1]*Sin[theta3]*
            (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
              Tan[phi2]))) + Cos[theta1]*(Sin[theta3] + Cos[theta3]*Sin[phi1]*
           (-(Cot[theta1 - theta2]*Sin[phi1]) + Cos[phi1]*Csc[theta1 - theta2]*
             Tan[phi2]))))^2/(1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2)], 
 (Cos[phi3]*Csc[theta1 - theta2]*Sin[phi1]*Sin[theta2 - theta3] + 
   Cos[phi1]*(Sin[phi3] - Cos[phi3]*Csc[theta1 - theta2]*Sin[theta1 - theta3]*
      Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
      Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]]



FullSimplify[fullmat.FullSimplify[xyz2sph[theta3, phi3, 1], conds], conds]

(* geodesics using planes? *)


(*

Claim: any great circle plane is z = ax + by because 0,0,0 must be in plane.

*)

(* theta is longitude here *)

xyz1 = sph2xyz[{theta1, phi1, 1}]
xyz2 = sph2xyz[{theta2, phi2, 1}]
xyz3 = sph2xyz[{theta3, phi3, 1}]

Solve[{
 a*xyz1[[1]] + b*xyz1[[2]] == xyz1[[3]],
 a*xyz2[[1]] + b*xyz2[[2]] == xyz2[[3]]
}, {a,b}, Reals]

line[t_] = xyz1 + t*(xyz2-xyz1)

curve[t_] = FullSimplify[line[t]/Norm[line[t]], conds]

dist[t_] = FullSimplify[VectorAngle[curve[t], xyz3], conds]

dist2[t_] = FullSimplify[VectorAngle[line[t], xyz3], conds]

(* this works out nicely:

FullSimplify[VectorAngle[curve[t], xyz3] - VectorAngle[line[t], xyz3], 
conds]                                                                          
yields 0

*)

FullSimplify[D[dist[t], t], conds]

ddist[t_] = FullSimplify[dist'[t], conds]

ddist2[t_] = FullSimplify[dist2'[t], conds]

ddist2[t_] = Simplify[dist2'[t], conds]

numddist2[t_] = Simplify[Numerator[ddist2[t]], conds]

Cos[dist2[t]]

dcosdist2[t_] = FullSimplify[D[Cos[dist2[t]], t], conds]

dcosdist2[t_] = D[Cos[dist2[t]], t]

Solve[dcosdist2[t] == 0, t]

Denominator[ddist2[t]]

Numerator[ddist2[t]]

Denominator[Numerator[ddist2[t]]]

FullSimplify[Numerator[ddist2[t]] /. t -> 0, conds]

mat1 = rotationMatrix[z, -theta1]

mat2 = rotationMatrix[y, -phi1]

FullSimplify[xyz2sph[mat1.xyz1], conds]

FullSimplify[xyz2sph[mat2.mat1.xyz1], conds]

FullSimplify[VectorAngle[mat2.mat1.xyz2, {0,1,0}], conds]

(* ArcCos[-(Cos[phi2] Sin[theta1 - theta2])] is above *)

mat3 = rotationMatrix[x, -ArcCos[-(Cos[phi2] Sin[theta1 - theta2])]]

mat3 = rotationMatrix[x, alpha]

Simplify[Tan[temp2137[[2]]], conds]

Simplify[Solve[Simplify[Numerator[Tan[temp2137[[2]]]], conds] == 0,
alpha], conds] /. C[1] -> 0

alpha0 = alpha /. 
(Simplify[Solve[Simplify[Numerator[Tan[temp2137[[2]]]], conds] ==
0, alpha], conds] /. C[1] -> 0)[[1]]

alpha0 becomes the tan of:

Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]

mat3 = rotationMatrix[x, 
 Tan[Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]]
]

or do i mean the neg of that?

mat3 = rotationMatrix[x, 
-Tan[Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]]
]

or lets be direct

alpha0 = wait I meant arctan

mat3 = rotationMatrix[x, ArcTan[
 Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2]
]]

FullSimplify[xyz2sph[mat3.mat2.mat1.xyz1], conds]

Simplify[xyz2sph[mat3.mat2.mat1.xyz2], conds]

temp2157 = xyz2sph[mat3.mat2.mat1.xyz2]

Simplify[Tan[temp2157[[2]]], conds] works!

Tan[temp2157[[2]]]

Numerator[Tan[temp2157[[2]]]]

rands = {phi1 -> Random[], phi2 -> Random[], theta1 -> Random[],
theta2 -> Random[]}

temp2157 /. rands

constant fails

(* these are working values:

mat1 = 

{{Cos[theta1], Sin[theta1], 0}, {-Sin[theta1], Cos[theta1], 0}, {0, 0, 1}}

mat2 = 

{{Cos[phi1], 0, Sin[phi1]}, {0, 1, 0}, {-Sin[phi1], 0, Cos[phi1]}}

mat3 = 

{{1, 0, 0}, 
 {0, 1/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
       Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2], 
  (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])/
   Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
        Tan[phi2])^2]}, 
 {0, -((Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
      Tan[phi2])/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
        Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]), 
  1/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
        Tan[phi2])^2]}}

to test fullmat:


conds = {
 -Pi <= theta1 <= Pi, -Pi <= theta2 <= Pi, -Pi <= theta3 <= Pi,
 -Pi/2 <= phi1 <= Pi/2, -Pi/2 <= phi2 <= Pi/2, -Pi/2 <= phi3 <= Pi/2,
 t > 0, t < 1
};

rands = {phi1 -> Random[Real, Pi]-Pi/2, phi2 -> Random[Real, Pi]-Pi/2, 
 theta1 -> Random[Real, 2*Pi]-Pi, theta2 -> Random[Real, 2*Pi]-Pi}

Chop[xyz2sph[fullmat.sph2xyz[theta1, phi1, 1]] /. rands]
Chop[xyz2sph[fullmat.sph2xyz[theta2, phi2, 1]] /. rands]






*)




temp2137 = Simplify[xyz2sph[mat3.mat2.mat1.xyz2], conds]

(* WRONG: FullSimplify[xyz2sph[mat1.mat2.xyz1], conds] *)

FullSimplify[xyz2sph[mat2.mat1.xyz2], conds]

xyz2sph[mat2.mat1.xyz2][[2]] /. ArcTan[a_, b_] -> ArcTan[b/a]

temp2119 = FullSimplify[xyz2sph[mat2.mat1.xyz2], conds][[2]]

arbmat = rotationMatrix[x, rx].rotationMatrix[y, ry].rotationMatrix[z, rz]

arbmat.xyz1

Solve[arbmat.xyz1 == {1,0,0}, {rx, ry, rz}]


(* another approach 26 Sep 2019 *)

(*

to keep variables as single English characters:

geodesic from lng r and lat s to lng u and lat v, point is lng x and lat y

*)

conds = {
 -Pi < r < Pi, -Pi < u < Pi, -Pi < x < Pi,
 -Pi/2 < s < Pi/2, -Pi/2 < v < Pi/2, -Pi/2 < y < Pi/2,
 0 < t < 1
};

f[t_] = t*sph2xyz[u, v, 1] + (1-t)*sph2xyz[r, s, 1]

g[t_] = Simplify[VectorAngle[f[t], sph2xyz[x,y,1]], conds]

Simplify[D[g[t], t], conds]

Solve[D[g[t], t] == 0, t, Reals]

h[t_] = Simplify[D[g[t], t], conds]

sol = t /. Solve[Numerator[h[t]] == 0, t]

sol2 = FullSimplify[sol, conds]

(* testing using the rotation thing *)

FullSimplify[sol2 /. {r -> 0, s -> 0}, conds]

FullSimplify[sol2 /. {r -> 0, s -> 0, u -> 0}, conds]

Simplify[xyz2sph[f[sol2]], conds]

xyz2sph[f[sol2]][[1]]

FullSimplify[xyz2sph[f[sol2]] /. {r -> 0, s -> 0, u -> 0}, conds]

VectorAngle[Flatten[f[sol2]], sph2xyz[x, y, 1]]

(*

https://gis.stackexchange.com/questions/346381/calculate-way-points-between-departure-and-destination

https://math.stackexchange.com/questions/23054/how-to-find-the-distance-between-a-point-and-line-joining-two-points-on-a-sphere

https://math.stackexchange.com/questions/161335/coordinates-of-interception-point-y-with-xy-being-the-shortest-distance-of-x-to?noredirect=1&lq=1

*)

(* different approach 3 Jan 2020 *)

(* {lngB, latB} to {lngD, latD} closest to {lngC, latC} *)

ptB = sph2xyz[lngB, latB, 1];
ptD = sph2xyz[lngD, latD, 1];
ptC = sph2xyz[lngC, latC, 1];

path[t_] = ptB + t*(ptD - ptB)



(* TODO: if f(x) < f(y) => g(x) < g(y) what is the name of the relation between f and g *)

(* below from Wolfram Cloud comps *)

ptB = sph2xyz[lngB, latB, 1];
ptD = sph2xyz[lngD, latD, 1];
ptC = sph2xyz[lngC, latC, 1];

path[t_] = ptB  + t*(ptD-ptB);

rules = {Cos[latB]* Cos[lngB] -> a, -Cos[latB] *Cos[lngB] + Cos[latD]*
Cos[lngD] -> b, -Cos[latB]* Sin[lngB] + Cos[latD]* Sin[lngD] -> c,
Cos[latB]*Sin[lngB] -> d, Sin[latB] -> e, Sin[latD] - Sin[latB] -> f,
Cos[latC]*Cos[lngC] -> x, Cos[latC]*Sin[lngC] -> y, Sin[latC] -> z };

rules2 = {a -> Cos[latB]* Cos[lngB] , b -> -Cos[latB] *Cos[lngB] +
Cos[latD]* Cos[lngD], c -> -Cos[latB]* Sin[lngB] + Cos[latD]*
Sin[lngD] , d -> Cos[latB]*Sin[lngB], e -> Sin[latB], f -> Sin[latD] -
Sin[latB], x -> Cos[latC]*Cos[lngC] , y -> Cos[latC]*Sin[lngC] , z ->
Sin[latC] };

(*
Out[19]= {t (-Cos[latB] Cos[lngB] + Cos[latD] Cos[lngD]) + Cos[latB] Cos[lngB], t (-Cos[latB] Sin[lngB] + Cos[latD] Sin[lngD]) + Cos[latB] Sin[lngB], t (Sin[latD] - Sin[latB]) + Sin[latB]}
*)

temp2006[t_] = Total[(path[t]-ptC)^2] /. rules;
temp2007[t_] = D[temp2006[t], t];
sol[t_] = t /.Simplify[Solve[temp2007[t] == 0, t]][[1]];

simps = Element[{lngB, latB, lngC, latC, lngD, latD}, Reals];

FullSimplify[sol[t] /. rules2, simps];
sol[t]
