(* solves cow1.png *)

(* circle of radius 1, find various points *)

b = {Cos[beta],Sin[beta]}
a = {1,0}

(* formula for AB as mx+c since were already using b *)

Solve[{a[[2]]==m*a[[1]]+c,b[[2]]==m*b[[1]]+c},{m,c}]

ab[x_] = m*x+c /. %[[1]]

(* trivial formula for OC *)

oc[x_] = Tan[alpha]*x

(* intersection *)

Solve[oc[x]==ab[x],x]
cx = x /. %[[1]]
c = {cx, oc[cx]}

(* distances AC and AB *)

dab = Sqrt[(b[[1]]-a[[1]])^2 + (b[[2]]-a[[2]])^2]
dac = Sqrt[(c[[1]]-a[[1]])^2 + (c[[2]]-a[[2]])^2]

(* and the answer *)

dac/dab


