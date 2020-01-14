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

oldLngLat[theta1_, phi_, theta2_, phi2_, thc_, phc_] =

{ArcTan[Cos[phc]*Cos[phi1]*Cos[thc]*Cos[theta1] - 
    (32*Cos[phi2]^2*Sin[phc]*Sin[theta1 - theta2]*(Sin[phi1]*Sin[theta2] - 
       Cos[phi1]*Sin[theta1]*Tan[phi2])*
      Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
           Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
      6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
      4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
      4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
      Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
      2*Cos[2*(phi2 + theta1 - theta2)] + 
      Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
      4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
      2*Cos[2*(phi1 - theta1 + theta2)] + 
      4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
      Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
      2*Cos[2*(phi2 - theta1 + theta2)] + 
      Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
      4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) + 
    (32*Cos[phc]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]^2*
      Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
           Csc[theta1 - theta2]*Tan[phi2])^2]*
      (Cos[theta2]*Csc[theta1 - theta2]*Sin[phi1]^2 + 
       Cos[phi1]*(Cos[phi1]*Sin[theta1] - Cos[theta1]*Csc[theta1 - theta2]*
          Sin[phi1]*Tan[phi2])))/(-20 - 4*Cos[2*phi1] + 
      6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
      4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
      4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
      Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
      2*Cos[2*(phi2 + theta1 - theta2)] + 
      Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
      4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
      2*Cos[2*(phi1 - theta1 + theta2)] + 
      4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
      Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
      2*Cos[2*(phi2 - theta1 + theta2)] + 
      Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
      4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]), 
   Cos[phc]*Cos[phi1]*Cos[thc]*Sin[theta1] - 
    (32*Cos[phi2]^2*Sin[phc]*Sin[theta1 - theta2]*((-Cos[theta2])*Sin[phi1] + 
       Cos[phi1]*Cos[theta1]*Tan[phi2])*
      Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
           Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
      6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
      4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
      4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
      Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
      2*Cos[2*(phi2 + theta1 - theta2)] + 
      Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
      4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
      2*Cos[2*(phi1 - theta1 + theta2)] + 
      4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
      Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
      2*Cos[2*(phi2 - theta1 + theta2)] + 
      Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
      4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) - 
    (32*Cos[phc]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]^2*
      (Cos[phi1]^2*Cos[theta1] - Csc[theta1 - theta2]*Sin[phi1]^2*
        Sin[theta2] + Cos[phi1]*Csc[theta1 - theta2]*Sin[phi1]*Sin[theta1]*
        Tan[phi2])*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
          Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])/
     (-20 - 4*Cos[2*phi1] + 6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 
      6*Cos[2*(phi1 + phi2)] + 4*Cos[2*theta1 - 2*theta2] + 
      2*Cos[2*(phi1 + theta1 - theta2)] + 
      4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
      Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
      2*Cos[2*(phi2 + theta1 - theta2)] + 
      Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
      4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
      2*Cos[2*(phi1 - theta1 + theta2)] + 
      4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
      Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
      2*Cos[2*(phi2 - theta1 + theta2)] + 
      Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
      4*Cos[2*phi1 + 2*phi2 - theta1 + theta2])], 
  ArcTan[Sqrt[(Cos[phc]*Cos[phi1]*Cos[thc]*Sin[theta1] - 
       (32*Cos[phi2]^2*Sin[phc]*Sin[theta1 - theta2]*
         ((-Cos[theta2])*Sin[phi1] + Cos[phi1]*Cos[theta1]*Tan[phi2])*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) - 
       (32*Cos[phc]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]^2*
         (Cos[phi1]^2*Cos[theta1] - Csc[theta1 - theta2]*Sin[phi1]^2*
           Sin[theta2] + Cos[phi1]*Csc[theta1 - theta2]*Sin[phi1]*Sin[theta1]*
           Tan[phi2])*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
             Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])/
        (-20 - 4*Cos[2*phi1] + 6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 
         6*Cos[2*(phi1 + phi2)] + 4*Cos[2*theta1 - 2*theta2] + 
         2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]))^2 + 
     (Cos[phc]*Cos[phi1]*Cos[thc]*Cos[theta1] - 
       (32*Cos[phi2]^2*Sin[phc]*Sin[theta1 - theta2]*(Sin[phi1]*Sin[theta2] - 
          Cos[phi1]*Sin[theta1]*Tan[phi2])*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) + 
       (32*Cos[phc]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]^2*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2]*
         (Cos[theta2]*Csc[theta1 - theta2]*Sin[phi1]^2 + 
          Cos[phi1]*(Cos[phi1]*Sin[theta1] - Cos[theta1]*Csc[theta1 - theta2]*
             Sin[phi1]*Tan[phi2])))/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]))^2], 
   Cos[phc]*Cos[thc]*Sin[phi1] - (32*Cos[phi1]*Cos[phi2]^2*Sin[phc]*
      Sin[theta1 - theta2]^2*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
          Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])/
     (-20 - 4*Cos[2*phi1] + 6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 
      6*Cos[2*(phi1 + phi2)] + 4*Cos[2*theta1 - 2*theta2] + 
      2*Cos[2*(phi1 + theta1 - theta2)] + 
      4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
      Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
      2*Cos[2*(phi2 + theta1 - theta2)] + 
      Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
      4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
      2*Cos[2*(phi1 - theta1 + theta2)] + 
      4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
      Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
      2*Cos[2*(phi2 - theta1 + theta2)] + 
      Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
      4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) - 
    (32*Cos[phc]*Cos[phi1]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]*
      (Cos[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Tan[phi2])*
      Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
           Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
      6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
      4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
      4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
      Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
      2*Cos[2*(phi2 + theta1 - theta2)] + 
      Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
      4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
      2*Cos[2*(phi1 - theta1 + theta2)] + 
      4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
      Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
      2*Cos[2*(phi2 - theta1 + theta2)] + 
      Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
      4*Cos[2*phi1 + 2*phi2 - theta1 + theta2])], 
  Sqrt[Abs[Cos[phc]*Cos[thc]*Sin[phi1] - (32*Cos[phi1]*Cos[phi2]^2*Sin[phc]*
         Sin[theta1 - theta2]^2*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
             Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])/
        (-20 - 4*Cos[2*phi1] + 6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 
         6*Cos[2*(phi1 + phi2)] + 4*Cos[2*theta1 - 2*theta2] + 
         2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) - 
       (32*Cos[phc]*Cos[phi1]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]*
         (Cos[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Tan[phi2])*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2])]^2 + 
    Abs[Cos[phc]*Cos[phi1]*Cos[thc]*Sin[theta1] - 
       (32*Cos[phi2]^2*Sin[phc]*Sin[theta1 - theta2]*
         ((-Cos[theta2])*Sin[phi1] + Cos[phi1]*Cos[theta1]*Tan[phi2])*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) - 
       (32*Cos[phc]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]^2*
         (Cos[phi1]^2*Cos[theta1] - Csc[theta1 - theta2]*Sin[phi1]^2*
           Sin[theta2] + Cos[phi1]*Csc[theta1 - theta2]*Sin[phi1]*Sin[theta1]*
           Tan[phi2])*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
             Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])/
        (-20 - 4*Cos[2*phi1] + 6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 
         6*Cos[2*(phi1 + phi2)] + 4*Cos[2*theta1 - 2*theta2] + 
         2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2])]^2 + 
    Abs[Cos[phc]*Cos[phi1]*Cos[thc]*Cos[theta1] - 
       (32*Cos[phi2]^2*Sin[phc]*Sin[theta1 - theta2]*(Sin[phi1]*Sin[theta2] - 
          Cos[phi1]*Sin[theta1]*Tan[phi2])*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2])/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2]) + 
       (32*Cos[phc]*Cos[phi2]^2*Sin[thc]*Sin[theta1 - theta2]^2*
         Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
              Csc[theta1 - theta2]*Tan[phi2])^2]*
         (Cos[theta2]*Csc[theta1 - theta2]*Sin[phi1]^2 + 
          Cos[phi1]*(Cos[phi1]*Sin[theta1] - Cos[theta1]*Csc[theta1 - theta2]*
             Sin[phi1]*Tan[phi2])))/(-20 - 4*Cos[2*phi1] + 
         6*Cos[2*phi1 - 2*phi2] - 4*Cos[2*phi2] + 6*Cos[2*(phi1 + phi2)] + 
         4*Cos[2*theta1 - 2*theta2] + 2*Cos[2*(phi1 + theta1 - theta2)] + 
         4*Cos[2*phi1 - 2*phi2 + theta1 - theta2] + 
         Cos[2*(phi1 - phi2 + theta1 - theta2)] + 
         2*Cos[2*(phi2 + theta1 - theta2)] + 
         Cos[2*(phi1 + phi2 + theta1 - theta2)] - 
         4*Cos[2*phi1 + 2*phi2 + theta1 - theta2] + 
         2*Cos[2*(phi1 - theta1 + theta2)] + 
         4*Cos[2*phi1 - 2*phi2 - theta1 + theta2] + 
         Cos[2*(phi1 - phi2 - theta1 + theta2)] + 
         2*Cos[2*(phi2 - theta1 + theta2)] + 
         Cos[2*(phi1 + phi2 - theta1 + theta2)] - 
         4*Cos[2*phi1 + 2*phi2 - theta1 + theta2])]^2]};





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

(* work below 4 Jan 2020 *)

a = {ax, ay, az};
b = {bx, by, bz};
c = {cx, cy, cz};

(* from a to b and how close do we get to c *)

pt[t_] = a  + t*(b-a);

cang[t_] = (pt[t].{cx, cy, cz})/Norm[pt[t]]

cang2[t_] = cang[t]^2

tval = (ax cx+ay cy+az cz)/(ax cx-bx cx+ay cy-by cy+az cz-bz cz);

cang2[tval]

(* work below 6 Jan 2020 *)

s = {sx, sy, sz};

t = {tx, ty, tz};

Cross[s,t]

In[4]:= Cross[Cross[s,t], s]

Out[4]= {-sy (sx ty - sy tx) + sz (-sx tz + sz tx), sx (sx ty - sy tx) - sz (sy tz - sz ty), -sx (-sx tz + sz tx) + sy (sy tz - sz ty)}

pplane = Cross[s,t]

perp = Cross[Cross[s,t], s]

s*Cos[th] + perp*Sin[th]

loc[th_] = Simplify[s*Cos[th] + perp*Sin[th]]

ang[th_] = {qx, qy, qz} . loc[th]

dang[th_] = D[ang[th], th]

m1 = Transpose[{s, perp, pplane}]

Simplify[m1, Element[{sx, sy, sz, tx, ty, tz}, Reals]]

Simplify[m1 /. {tz^2 -> 1-tx^2-ty^2, sz^2 -> 1-sx^2-sy^2}, 
 Element[{sx, sy, sz, tx, ty, tz}, Reals]]

m2 = Simplify[Inverse[m1]]

conds2 = {Element[{sx, sy, sz, tx, ty, tz, qx, qy, qz}, Reals],
 sx^2 + sy^2 + sz^2 == 1, tx^2 + ty^2 + tz^2 == 1, qx^2 + qy^2 + qz^2 == 1}

random := Module[{t}, t = RandomReal[{-1, 1}, 3]; Return[t/Norm[t]]];

Clear[pplane];
pplane[u1_, u2_] = Cross[u1,u2]/Norm[Cross[u1, u2]];

Clear[perp];
perp[u1_, u2_] = Cross[pplane[u1, u2], u1]/Norm[Cross[pplane[u1, u2], u1]]

Clear[m1];
m1[u1_, u2_] := Transpose[{u1, perp[u1, u2], pplane[u1, u2]}]

Clear[m2];
m2[u1_, u2_] := Inverse[m1[u1,u2]]

v1 = random
v2 = random

pplane[v1, v2]
perp[v1, v2]
m1[v1, v2]

RANDOM NUMBERS:

0.56979, -0.00200045, -1.59657, 0.344406, 0.964949, -1.1642

(* work below 7 Jan 2020 *)

fullmat = {{Cos[phi1]*Cos[theta1], Cos[phi1]*Sin[theta1], Sin[phi1]}, 
  {(Csc[theta1 - theta2]*((-6 + 2*Cos[2*phi1] + Cos[2*phi1 - 2*theta1] + 
        2*Cos[2*theta1] + Cos[2*(phi1 + theta1)])*Cos[theta2] - 
      2*Sin[phi1]^2*Sin[2*theta1]*Sin[theta2] + 4*Cos[theta1]*
       ((1 + Cos[phi1]^2)*Sin[theta1]*Sin[theta2] + Sin[2*phi1]*Tan[phi2])))/
    (8*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
         Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]), 
   -((Csc[theta1 - theta2]*((-(3 + Cos[2*phi1]))*Cos[theta1]*Cos[theta2]*
        Sin[theta1] + Cos[theta2]*Sin[phi1]^2*Sin[2*theta1] + Sin[theta2] - 
       Cos[phi1]^2*Sin[theta2] + (3 + Cos[2*phi1])*Cos[theta1]^2*
        Sin[theta2] + Sin[phi1]^2*Sin[theta2] + Sin[theta1]^2*Sin[theta2] - 
       Cos[phi1]^2*Sin[theta1]^2*Sin[theta2] + Sin[phi1]^2*Sin[theta1]^2*
        Sin[theta2] - 4*Cos[phi1]*Sin[phi1]*Sin[theta1]*Tan[phi2]))/
     (4*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*
           Csc[theta1 - theta2]*Tan[phi2])^2])), 
   (Cos[phi1]*Csc[theta1 - theta2]*(Cos[theta1 - theta2]*Sin[phi1] - 
      Cos[phi1]*Tan[phi2]))/
    Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
         Tan[phi2])^2]}, 
  {(Csc[theta1 - theta2]*(Sin[phi1]*Sin[theta2] - Cos[phi1]*Sin[theta1]*
       Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
        Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2], 
   (Csc[theta1 - theta2]*((-Cos[theta2])*Sin[phi1] + 
      Cos[phi1]*Cos[theta1]*Tan[phi2]))/
    Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
         Tan[phi2])^2], Cos[phi1]/
    Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - Cos[phi1]*Csc[theta1 - theta2]*
         Tan[phi2])^2]}}

{ArcTan[Cos[phc]*Cos[phi1]*Cos[thc - theta1] + Sin[phc]*Sin[phi1], 
   (Csc[theta1 - theta2]*(Cos[phc]*(2*Cos[2*phi1 - phi2 + thc - theta1] - 
        2*Cos[2*phi1 + phi2 + thc - theta1] + 
        2*Cos[2*phi1 - phi2 - thc + theta1] - 
        2*Cos[2*phi1 + phi2 - thc + theta1] + Cos[2*phi1 - phi2 + thc - 
          theta2] - 6*Cos[phi2 + thc - theta2] + 
        Cos[2*phi1 + phi2 + thc - theta2] + Cos[2*phi1 - phi2 - thc + 
          2*theta1 - theta2] + 2*Cos[phi2 - thc + 2*theta1 - theta2] + 
        Cos[2*phi1 + phi2 - thc + 2*theta1 - theta2] + 
        Cos[2*phi1 - phi2 - thc + theta2] - 6*Cos[phi2 - thc + theta2] + 
        Cos[2*phi1 + phi2 - thc + theta2] + Cos[2*phi1 - phi2 + thc - 
          2*theta1 + theta2] + 2*Cos[phi2 + thc - 2*theta1 + theta2] + 
        Cos[2*phi1 + phi2 + thc - 2*theta1 + theta2])*Sec[phi2] + 
      8*Sin[phc]*(Cos[theta1 - theta2]*Sin[2*phi1] - 
        2*Cos[phi1]^2*Tan[phi2])))/
    (16*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
         Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])], 
  ArcTan[Sqrt[(Cos[phc]*Cos[phi1]*Cos[thc - theta1] + Sin[phc]*Sin[phi1])^2 + 
     (Csc[theta1 - theta2]^2*(Cos[phc]*(2*Cos[2*phi1 - phi2 + thc - theta1] - 
           2*Cos[2*phi1 + phi2 + thc - theta1] + 
           2*Cos[2*phi1 - phi2 - thc + theta1] - 
           2*Cos[2*phi1 + phi2 - thc + theta1] + Cos[2*phi1 - phi2 + thc - 
             theta2] - 6*Cos[phi2 + thc - theta2] + 
           Cos[2*phi1 + phi2 + thc - theta2] + Cos[2*phi1 - phi2 - thc + 
             2*theta1 - theta2] + 2*Cos[phi2 - thc + 2*theta1 - theta2] + 
           Cos[2*phi1 + phi2 - thc + 2*theta1 - theta2] + 
           Cos[2*phi1 - phi2 - thc + theta2] - 6*Cos[phi2 - thc + theta2] + 
           Cos[2*phi1 + phi2 - thc + theta2] + Cos[2*phi1 - phi2 + thc - 
             2*theta1 + theta2] + 2*Cos[phi2 + thc - 2*theta1 + theta2] + 
           Cos[2*phi1 + phi2 + thc - 2*theta1 + theta2])*Sec[phi2] + 
         8*Sin[phc]*(Cos[theta1 - theta2]*Sin[2*phi1] - 2*Cos[phi1]^2*
            Tan[phi2]))^2)/(256*(1 + (Cot[theta1 - theta2]*Sin[phi1] - 
          Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2))], 
   ((-Cos[phc])*Csc[theta1 - theta2]*Sin[phi1]*Sin[thc - theta2] + 
     Cos[phi1]*(Sin[phc] + Cos[phc]*Csc[theta1 - theta2]*Sin[thc - theta1]*
        Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
        Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]], 
  Sqrt[Abs[Cos[phc]*Cos[phi1]*Cos[thc - theta1] + Sin[phc]*Sin[phi1]]^2 + 
    (1/256)*Abs[(Csc[theta1 - theta2]*
         (Cos[phc]*(2*Cos[2*phi1 - phi2 + thc - theta1] - 
            2*Cos[2*phi1 + phi2 + thc - theta1] + 
            2*Cos[2*phi1 - phi2 - thc + theta1] - 
            2*Cos[2*phi1 + phi2 - thc + theta1] + Cos[2*phi1 - phi2 + thc - 
              theta2] - 6*Cos[phi2 + thc - theta2] + 
            Cos[2*phi1 + phi2 + thc - theta2] + Cos[2*phi1 - phi2 - thc + 
              2*theta1 - theta2] + 2*Cos[phi2 - thc + 2*theta1 - theta2] + 
            Cos[2*phi1 + phi2 - thc + 2*theta1 - theta2] + 
            Cos[2*phi1 - phi2 - thc + theta2] - 6*Cos[phi2 - thc + theta2] + 
            Cos[2*phi1 + phi2 - thc + theta2] + Cos[2*phi1 - phi2 + thc - 
              2*theta1 + theta2] + 2*Cos[phi2 + thc - 2*theta1 + theta2] + 
            Cos[2*phi1 + phi2 + thc - 2*theta1 + theta2])*Sec[phi2] + 
          8*Sin[phc]*(Cos[theta1 - theta2]*Sin[2*phi1] - 2*Cos[phi1]^2*
             Tan[phi2])))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
            Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]]^2 + 
    Abs[((-Cos[phc])*Csc[theta1 - theta2]*Sin[phi1]*Sin[thc - theta2] + 
        Cos[phi1]*(Sin[phc] + Cos[phc]*Csc[theta1 - theta2]*Sin[thc - theta1]*
           Tan[phi2]))/Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
           Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2]]^2]}



ArcTan[Cos[phc]*Cos[phi1]*Cos[thc - theta1] + Sin[phc]*Sin[phi1], 
  (Csc[theta1 - theta2]*(Cos[phc]*(2*Cos[2*phi1 - phi2 + thc - theta1] - 
       2*Cos[2*phi1 + phi2 + thc - theta1] + 
       2*Cos[2*phi1 - phi2 - thc + theta1] - 
       2*Cos[2*phi1 + phi2 - thc + theta1] + 
       Cos[2*phi1 - phi2 + thc - theta2] - 6*Cos[phi2 + thc - theta2] + 
       Cos[2*phi1 + phi2 + thc - theta2] + Cos[2*phi1 - phi2 - thc + 
         2*theta1 - theta2] + 2*Cos[phi2 - thc + 2*theta1 - theta2] + 
       Cos[2*phi1 + phi2 - thc + 2*theta1 - theta2] + 
       Cos[2*phi1 - phi2 - thc + theta2] - 6*Cos[phi2 - thc + theta2] + 
       Cos[2*phi1 + phi2 - thc + theta2] + Cos[2*phi1 - phi2 + thc - 
         2*theta1 + theta2] + 2*Cos[phi2 + thc - 2*theta1 + theta2] + 
       Cos[2*phi1 + phi2 + thc - 2*theta1 + theta2])*Sec[phi2] + 
     8*Sin[phc]*(Cos[theta1 - theta2]*Sin[2*phi1] - 
       2*Cos[phi1]^2*Tan[phi2])))/
   (16*Sqrt[1 + (Cot[theta1 - theta2]*Sin[phi1] - 
        Cos[phi1]*Csc[theta1 - theta2]*Tan[phi2])^2])]

(*

****** TODO: SUMMARY

I couldn't find a closed form solution to this question, but I got pretty close.

If the longitude and latitude of point A is `{tha, pha}` and the latitude of point B is `{thb, phb}`, there is a rigid rotation that maps A to longitude and latitude 0 and maps B to latitude 0, with longitude determined by its distance from A. The matrix that performs this rotation is:

$
\left(
\begin{array}{ccc}
 \cos (\text{pha}) \cos (\text{tha}) & \cos (\text{pha}) \sin (\text{tha}) & \sin
   (\text{pha}) \\
 \frac{\sin (\text{pha}) \cos (\text{tha}) (\tan (\text{ph}) \cos (\text{pha}) \csc
   (\text{tha}-\text{thb})-\sin (\text{pha}) \cot (\text{tha}-\text{thb}))-\sin
   (\text{tha})}{\sqrt{(\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\tan
   (\text{ph}) \cos (\text{pha}) \csc (\text{tha}-\text{thb}))^2+1}} & \frac{\sin
   (\text{pha}) \sin (\text{tha}) (\tan (\text{ph}) \cos (\text{pha}) \csc
   (\text{tha}-\text{thb})-\sin (\text{pha}) \cot (\text{tha}-\text{thb}))+\cos
   (\text{tha})}{\sqrt{(\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\tan
   (\text{ph}) \cos (\text{pha}) \csc (\text{tha}-\text{thb}))^2+1}} & \frac{\cos
   (\text{pha}) (\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\tan (\text{ph}) \cos
   (\text{pha}) \csc (\text{tha}-\text{thb}))}{\sqrt{(\sin (\text{pha}) \cot
   (\text{tha}-\text{thb})-\tan (\text{ph}) \cos (\text{pha}) \csc
   (\text{tha}-\text{thb}))^2+1}} \\
 \frac{\csc (\text{tha}-\text{thb}) (\sin (\text{pha}) \sin (\text{thb})-\tan
   (\text{ph}) \cos (\text{pha}) \sin (\text{tha}))}{\sqrt{(\sin (\text{pha}) \cot
   (\text{tha}-\text{thb})-\tan (\text{ph}) \cos (\text{pha}) \csc
   (\text{tha}-\text{thb}))^2+1}} & \frac{\csc (\text{tha}-\text{thb}) (\tan
   (\text{ph}) \cos (\text{pha}) \cos (\text{tha})-\sin (\text{pha}) \cos
   (\text{thb}))}{\sqrt{(\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\tan
   (\text{ph}) \cos (\text{pha}) \csc (\text{tha}-\text{thb}))^2+1}} & \frac{\cos
   (\text{pha})}{\sqrt{(\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\tan
   (\text{ph}) \cos (\text{pha}) \csc (\text{tha}-\text{thb}))^2+1}} \\
\end{array}
\right)
$

If your point X (which we'll call C since I am generalizing this answer) originally had longitude/latitude of {thc, phc}, it's latitude and longitude after transformation will be:

$
\left\{\tan ^{-1}\left(\sqrt{\frac{(\cos (\text{phc}) (\cos (\text{tha}) (\sin
   (\text{pha}) \cos (\text{thc}) (\cos (\text{pha}) \tan (\text{phb}) \csc
   (\text{tha}-\text{thb})-\sin (\text{pha}) \cot (\text{tha}-\text{thb}))+\sin
   (\text{thc}))-\sin (\text{tha}) (\sin (\text{pha}) \sin (\text{thc}) (\sin
   (\text{pha}) \cot (\text{tha}-\text{thb})-\cos (\text{pha}) \tan (\text{phb}) \csc
   (\text{tha}-\text{thb}))+\cos (\text{thc})))+\cos (\text{pha}) \sin (\text{phc})
   (\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\cos (\text{pha}) \tan
   (\text{phb}) \csc (\text{tha}-\text{thb})))^2}{(\sin (\text{pha}) \cot
   (\text{tha}-\text{thb})-\cos (\text{pha}) \tan (\text{phb}) \csc
   (\text{tha}-\text{thb}))^2+1}+(\cos (\text{pha}) \cos (\text{phc}) \cos
   (\text{tha}-\text{thc})+\sin (\text{pha}) \sin (\text{phc}))^2},\frac{\cos
   (\text{pha}) (\sin (\text{phc})-\tan (\text{phb}) \cos (\text{phc}) \csc
   (\text{tha}-\text{thb}) \sin (\text{tha}-\text{thc}))+\sin (\text{pha}) \cos
   (\text{phc}) \csc (\text{tha}-\text{thb}) \sin
   (\text{thb}-\text{thc})}{\sqrt{(\sin (\text{pha}) \cot
   (\text{tha}-\text{thb})-\cos (\text{pha}) \tan (\text{phb}) \csc
   (\text{tha}-\text{thb}))^2+1}}\right),\tan ^{-1}\left(\sqrt{\frac{(\cos
   (\text{phc}) (\cos (\text{tha}) (\sin (\text{pha}) \cos (\text{thc}) (\cos
   (\text{pha}) \tan (\text{phb}) \csc (\text{tha}-\text{thb})-\sin (\text{pha}) \cot
   (\text{tha}-\text{thb}))+\sin (\text{thc}))-\sin (\text{tha}) (\sin (\text{pha})
   \sin (\text{thc}) (\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\cos
   (\text{pha}) \tan (\text{phb}) \csc (\text{tha}-\text{thb}))+\cos
   (\text{thc})))+\cos (\text{pha}) \sin (\text{phc}) (\sin (\text{pha}) \cot
   (\text{tha}-\text{thb})-\cos (\text{pha}) \tan (\text{phb}) \csc
   (\text{tha}-\text{thb})))^2}{(\sin (\text{pha}) \cot (\text{tha}-\text{thb})-\cos
   (\text{pha}) \tan (\text{phb}) \csc (\text{tha}-\text{thb}))^2+1}+(\cos
   (\text{pha}) \cos (\text{phc}) \cos (\text{tha}-\text{thc})+\sin (\text{pha}) \sin
   (\text{phc}))^2},\frac{\cos (\text{pha}) (\sin (\text{phc})-\tan (\text{phb}) \cos
   (\text{phc}) \csc (\text{tha}-\text{thb}) \sin (\text{tha}-\text{thc}))+\sin
   (\text{pha}) \cos (\text{phc}) \csc (\text{tha}-\text{thb}) \sin
   (\text{thb}-\text{thc})}{\sqrt{(\sin (\text{pha}) \cot
   (\text{tha}-\text{thb})-\cos (\text{pha}) \tan (\text{phb}) \csc
   (\text{tha}-\text{thb}))^2+1}}\right)\right\}
$

The translated latitude of C gives its distance from the equator, and thus the distance from the original C to the great circle connecting A and B.

The translated longitude of C tells where on the equator C is closest to the great circle connecting A and B, 

**** the issue is if not between A and B

**** TODO: diagrams (Geogebra)

*)

(* work below 8 Jan 2020 *)

points A and B and C

cross A and B to get vect v1 perp to both

cross A and v1 to get vect v2 in plane of A and B and perp to A

note v1 and v2 form basis for great circle through A and B

v1*cos(th) + v2*sin(th)

cross v1 and C and call it v3

cross v3 and v1 call it v4

TO DO: note normality

a = sph2xyz[tha, pha, 1]

b = sph2xyz[thb, phb, 1]

c = sph2xyz[thc, phc, 1]

v1 = Simplify[Cross[a,b]]

v2 = Simplify[Cross[a, v1]]

v3 = Simplify[Cross[v1, c]]

v4 = Simplify[Cross[v3, v1]]

(*

This is not an answer, but I've written a very basic proof-of-concept page at https://barrycarter.github.io/pages/REPL/WAYPOINTS/ which computes any number of FAA facility waypoints between a given pair of longitudes and latitudes. Notes:

  - Source code: https://github.com/barrycarter/pages/tree/master/REPL/WAYPOINTS

  - The source code is in JavaScript, and all files you need to run it are in the source code above. The code is entirely client-side and does not make any server connections. If you download it, you should be able to run it even without an Internet connection.

  - The functions I use are in bclib-staging.js and bclib.js and should be fairly easy to port to other languages.

  - The file stations.js is a JSON-ification of https://www.faa.gov/airports/airport_safety/airportdata_5010/menu/nfdcfacilitiesexport.cfm?Region=&District=&State=&County=&City=&Use=&Certification=

  - The file above only includes FAA facilities, which are pretty much limited to the United States (though this does include the American Samoa, Guam, etc), so, once you get away from the United States, the nearest stations can be quite far away.

  - If you or anyone has a better list I can use, I would be happy to update my code.

  - Because my code finds the closest FAA facility to a given waypoint, it sometimes yields the same FAA facility for 2 or more waypoints. This is especially true for flights outside of the United States.

  - I discovered turf.js (http://turfjs.org/) fairly early in the process, but didn't realize how powerful it was until later. My code could doubtless be rewritten much better with turf.js

  - I livestreamed my attempt to solve this problem and the recordings are available at: https://www.youtube.com/playlist?list=PLQiTKaefaTLpfUVJETwWX31IxLypqA7xy (videos 62-72, ie, those that mention waypoints, geography, or great circle).

I'm hesitant to post this link, because, in addition to the usual worthlessness of my videos, I spent a lot of time trying to find a closed-form formula for points along a great circle. Though I eventually succeeded, the resulting 250+ line formula is far too ugly for use.

(* work below 12 Jan 2020 *)

a point on geodesic must have angle from A + angle from B = angle between A and B?


s = {sx, sy, sz};
t = {tx, ty, tz};

q = {qx, qy, qz};

s.q + t.q == s.t

Solve[s.q + t.q == s.t, {qx, qy, qz}]

Solve[s.q/Norm[s.q] + t.q/Norm[t.q] == s.t, {qx, qy, qz}]

a = sph2xyz[tha, pha, 1];
b = sph2xyz[thb, phb, 1];
c = sph2xyz[thc, phc, 1];

Solve[a.c + b.c == a.c, {thc, phc}, Reals]

(*

Subject: Simpler closed form for spherical coordinates of points on great circle?

Short version: how to simplify this expression given these conditions? Note that `expr[[3]]` is equal to 1, although Mathematica won't simplify it as such.

<pre><code>

conds = {-Pi < tha, tha < Pi, -Pi < thb, thb < Pi, -Pi/2 < pha, pha <
Pi/2, -Pi/2 < phb, phb < Pi/2};

expr = {ArcTan[Cos[pha]*Cos[tha]*Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
         Sin[pha]*Sin[phb]]] + (((-Cos[pha])*Cos[tha]*Sin[pha]*Sin[phb] + 
       Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[tha - thb]))*
      Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + Sin[pha]*Sin[phb]]])/
     Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
           Cos[pha]*Sin[phb])]^2 + (Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] - 
         Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[tha - thb]))^
        2 + (Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + Cos[pha]^2*Cos[phb]*
          Cos[tha]*Sin[tha - thb] - Cos[phb]*Sin[pha]^2*Sin[thb])^2], 
   Cos[pha]*Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
         Sin[pha]*Sin[phb]]]*Sin[tha] - 
    ((Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + Cos[pha]^2*Cos[phb]*Cos[tha]*
        Sin[tha - thb] - Cos[phb]*Sin[pha]^2*Sin[thb])*
      Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + Sin[pha]*Sin[phb]]])/
     Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
           Cos[pha]*Sin[phb])]^2 + (Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] - 
         Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[tha - thb]))^
        2 + (Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + Cos[pha]^2*Cos[phb]*
          Cos[tha]*Sin[tha - thb] - Cos[phb]*Sin[pha]^2*Sin[thb])^2]], 
  ArcTan[
   Sqrt[(Cos[pha]*Cos[tha]*Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
            Sin[pha]*Sin[phb]]] + (((-Cos[pha])*Cos[tha]*Sin[pha]*Sin[phb] + 
          Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*
             Sin[tha - thb]))*Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
             Sin[pha]*Sin[phb]]])/
        Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
              Cos[pha]*Sin[phb])]^2 + (Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] - 
            Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[
                tha - thb]))^2 + (Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + 
            Cos[pha]^2*Cos[phb]*Cos[tha]*Sin[tha - thb] - Cos[phb]*Sin[pha]^2*
             Sin[thb])^2])^2 + 
     (Cos[pha]*Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
            Sin[pha]*Sin[phb]]]*Sin[tha] - 
       ((Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + Cos[pha]^2*Cos[phb]*Cos[tha]*
           Sin[tha - thb] - Cos[phb]*Sin[pha]^2*Sin[thb])*
         Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + Sin[pha]*Sin[phb]]])/
        Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
              Cos[pha]*Sin[phb])]^2 + (Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] - 
            Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[
                tha - thb]))^2 + (Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + 
            Cos[pha]^2*Cos[phb]*Cos[tha]*Sin[tha - thb] - Cos[phb]*Sin[pha]^2*
             Sin[thb])^2])^2], 
   Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + Sin[pha]*Sin[phb]]]*
     Sin[pha] + (Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
       Cos[pha]*Sin[phb])*Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
          Sin[pha]*Sin[phb]]])/
     Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
           Cos[pha]*Sin[phb])]^2 + (Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] - 
         Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[tha - thb]))^
        2 + (Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + Cos[pha]^2*Cos[phb]*
          Cos[tha]*Sin[tha - thb] - Cos[phb]*Sin[pha]^2*Sin[thb])^2]], 
  Sqrt[
   Abs[Cos[pha]*Cos[tha]*Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
            Sin[pha]*Sin[phb]]] + ((Cos[phb]*Cos[thb]*Sin[pha]^2 - 
          Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] + Cos[pha]^2*Cos[phb]*Sin[tha]*
           Sin[tha - thb])*Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
             Sin[pha]*Sin[phb]]])/
        Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
              Cos[pha]*Sin[phb])]^2 + (Cos[phb]*Cos[thb]*Sin[pha]^2 - 
            Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] + Cos[pha]^2*Cos[phb]*
             Sin[tha]*Sin[tha - thb])^2 + (Cos[pha]*Sin[pha]*Sin[phb]*
             Sin[tha] + Cos[pha]^2*Cos[phb]*Cos[tha]*Sin[tha - thb] - 
            Cos[phb]*Sin[pha]^2*Sin[thb])^2]]^2 + 
    Abs[Cos[pha]*Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
            Sin[pha]*Sin[phb]]]*Sin[tha] - 
       ((Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + Cos[pha]^2*Cos[phb]*Cos[tha]*
           Sin[tha - thb] - Cos[phb]*Sin[pha]^2*Sin[thb])*
         Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + Sin[pha]*Sin[phb]]])/
        Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
              Cos[pha]*Sin[phb])]^2 + (Cos[phb]*Cos[thb]*Sin[pha]^2 - 
            Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] + Cos[pha]^2*Cos[phb]*
             Sin[tha]*Sin[tha - thb])^2 + (Cos[pha]*Sin[pha]*Sin[phb]*
             Sin[tha] + Cos[pha]^2*Cos[phb]*Cos[tha]*Sin[tha - thb] - 
            Cos[phb]*Sin[pha]^2*Sin[thb])^2]]^2 + 
    Abs[Cos[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + Sin[pha]*Sin[phb]]]*
        Sin[pha] + (Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
          Cos[pha]*Sin[phb])*Sin[r*ArcCos[Cos[pha]*Cos[phb]*Cos[tha - thb] + 
             Sin[pha]*Sin[phb]]])/
        Sqrt[Abs[Cos[pha]*((-Cos[phb])*Cos[tha - thb]*Sin[pha] + 
              Cos[pha]*Sin[phb])]^2 + (Cos[pha]*Cos[tha]*Sin[pha]*Sin[phb] - 
            Cos[phb]*(Cos[thb]*Sin[pha]^2 + Cos[pha]^2*Sin[tha]*Sin[
                tha - thb]))^2 + (Cos[pha]*Sin[pha]*Sin[phb]*Sin[tha] + 
            Cos[pha]^2*Cos[phb]*Cos[tha]*Sin[tha - thb] - Cos[phb]*Sin[pha]^2*
             Sin[thb])^2]]^2]}


</code></pre>

Longer version:

Given two points A and B on the unit sphere identified by longitude and latitude `{tha, pha}` and `{thb, phb}` (where `th` is the longitude), we can do the following:

<pre><code>

(* using Wolfram Cloud *)

$Version

12.0.0 for Linux x86 (64-bit) (April 7, 2019)

(* using my own version of xyz2sph and sph2xyz (instead of CoordinateTransform) so spherical coordinates are in longitude, latitude, radius order *)

xyz2sph[x_,y_,z_] = {ArcTan[x,y], ArcTan[Sqrt[x^2+y^2],z], Norm[{x,y,z}]};
sph2xyz[th_,ph_,r_] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]};

xyz2sph[l_] := Apply[xyz2sph,l];
sph2xyz[l_] := Apply[sph2xyz,l];

(* all variables are angles, longitudes limited to +-Pi and latitudues
limited to +-Pi/2 *)

conds = {-Pi < tha, tha < Pi, -Pi < thb, thb < Pi, -Pi/2 < pha, pha < Pi/2, -Pi/2 < phb, phb < Pi/2};

(* convert longitude, latitude to Cartesian *)

ptA = sph2xyz[tha, pha, 1];
ptB = sph2xyz[thb, phb, 1];

(* find the cross product, a (not necessarily unit) vector perpendicular to both *)

(* Simplify at each step to make things easier, although some of these
Simplify's will have no effect *)

perp = Simplify[Cross[ptA, ptB], conds];

(* find the vector perpendicular to perp and ptA, which lies in the
same plane as A and B; the order of the cross product is chosen so
that the parametrization I will do later goes from A to B *)

planar = Simplify[Cross[perp, ptA], conds];

(* normalize the planar vector *)

planarNorm= Simplify[planar/Norm[planar], conds];

(* distance-preserving parameterization of the great circle from A to B *)

point[t_] = Simplify[ptA*Cos[t] + planarNorm*Sin[t], conds];

(* the angular distance between A and B *)

angDist = Simplify[VectorAngle[ptA, ptB], conds];

(* the Cartesian vector "r" of the way between A and B on the great circle *)

rWayCartesian[r_] = Simplify[point[r*angDist], conds];

(* and the spherical equivalent *)

rWaySpherical[r_] = Simplify[xyz2sph[rWayCartesian[r]], conds];

(* which yields the nasty formula above *)

*)

</code></pre>

Notes:

  - The above is also at https://www.wolframcloud.com/obj/a1b56ad7-4deb-4afd-aa53-436ec91b4c48

  - I suppressed most of the output above (except for `$Version`), because I wasn't sure if it would be useful.

  - I realize most of my terms above are functions of `tha`, `pha`, `thb`, `phb`, but I've written them as non-functions for simplicity.

  - I know that https://mathematica.stackexchange.com/questions/142033/equally-spaced-points-on-a-great-circle-arc-between-2-points asks a similar question, but I don't think a closed form is given explicitly.
