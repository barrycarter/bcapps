(* probably of no help to http://physics.stackexchange.com/questions/254391/applications-of-octonions-in-special-relativity *)

(* section 3.3 of baez paper *)

t + Ix -> (t+vx)/Sqrt[1-v^2] + I*(tv+x)/Sqrt[1-v^2]

im[t_,x_] = t+I*x

Solve[(a*im[t,x]+b)/(c*im[t,x]+d) == im[
 (t+v*x)/Sqrt[1-v^2], (t*v+x)/Sqrt[1-v^2]], {a,b,c,d}]

Solve[{(a*im[t,x]+b)/(c*im[t,x]+d) == im[
 (t+v*x)/Sqrt[1-v^2], (t*v+x)/Sqrt[1-v^2]],
 c==0, a==0},
{a,b,c,d}]

