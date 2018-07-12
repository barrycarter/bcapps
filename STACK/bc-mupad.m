(*

https://math.stackexchange.com/questions/2846682/is-it-possible-to-solve-this-equation-symbolicaly-with-mathematica-mupad

original eqs:

o := ode(p3'(z) = (-diff(p1,z)*p2-diff(p2,z)*p1-8*diff(p2,z)-8*diff(p1,z)/p0+8*p1*diff(p0,z)/p0^2-diff(p0,z)*p3(z))/p0,p3(z))

p0:=sqrt(1+64*(1-z))
p1:=8*(1/sqrt(1+64*(1-z))-1)
p2:=(-ln(sqrt(1+64*(1-z)))+4*(1-1/(1+64*(1-z))))/sqrt((1+64*(1-z)))

*)

p0[z_] = Sqrt[1+64*(1-z)]

p1[z_] = 8*(1/Sqrt[1+64*(1-z)]-1)

p2[z_] = (-Log[Sqrt[1+64*(1-z)]]+4*(1-1/(1+64*(1-z))))/Sqrt[(1+64*(1-z))]

DSolve[

p3'[z] ==

(-p1'[z]*p2[z]-
p2'[z]*p1[z]-8*p2'[z]-8*p1'[z]/p0[z]+8*p1[z]*p0'[z]/p0[z]^2-
p0'[z]*p3[z])/p0[z], p3[z], z

]



(* and then DSolve above *)

