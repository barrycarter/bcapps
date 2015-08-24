(* parametric equations to find conjunctions *)

x[t_] = a*(1 - t)*Cos[alpha] + c*t*Cos[gamma];
y[t_] = a*(1 - t)*Sin[alpha] + c*t*Sin[gamma];

Solve[{b*Cos[beta]==x[t],b*Sin[beta]==y[t]},beta,Reals]



