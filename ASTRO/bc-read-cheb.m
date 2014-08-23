(* given the output of bc-read-cheb.pl, a list of coefficients,
determine daily Taylor series to within 22m precision of Chebyshev
polynomials *)

(* day 0 = 1949-Dec-14 00:00:00.0000 UTC = JD 2433264.500000000 *)

(* 1970-01-01 = day 7323, 2014-01-01 = day 23394 *)

(* split coeffs into groups of ncoeff and then 3 axes *)
coeffs = Partition[Partition[coeffs,ncoeff],3];

(* "blank" Chebyshev polynomial list and Taylor series, from 0 to ncoeff-1 *)
cheb = Table[ChebyshevT[i,t],{i,0,ncoeff-1}]
taylor = Table[t^i,{i,0,ncoeff-1}]

(* function that semi-efficiently computes Taylor polynomial for
interval [a,b] treated as [0,1] where c[i] are the Chebyshev
coefficients up to order 14 (polynomial order 13) *)

cheb2tay[a_,b_] := cheb2tay[a,b] = 
CoefficientList[Sum[c[i+1]*ChebyshevT[i,x],{i,0,13}] /. x-> a+frac*(b-a),frac]

cheb2tay[0,1/8] /. c[i_] -> coeffs[[2924,1,i]]

Table[{2*i/ndays-1,2*(i+1)/ndays-1}, {i,0,ndays-1}]

t1 = Table[cheb2tay[2*i/ndays-1, 2*(i+1)/ndays-1],{i,0,ndays-1}] /. 
 c[i_] -> coeffs[[2924,1,i]] 

t1 = Transpose[Table[Table[cheb2tay[2*i/ndays-1,
2*(i+1)/ndays-1],{i,0,ndays-1}] /. c[i_] -> coeffs[[2924,axes,i]],
{axes,1,3}]]

t1 = Table[Transpose[Table[Table[cheb2tay[2*i/ndays-1,
2*(i+1)/ndays-1],{i,0,ndays-1}] /. c[i_] -> coeffs[[n,axes,i]],
{axes,1,3}]], {n,1,Length[coeffs]}];

Timing[Table[cheb2tay[2*i/ndays-1,2*(i+1)/ndays-1],{i,0,ndays-1}] /. 
 c[i_] -> coeffs[[1234,1,i]]]

t1 =
Timing[Table[Table[cheb2tay[2*i/ndays-1,2*(i+1)/ndays-1],{i,0,ndays-1}]
/. c[i_] -> coeffs[[n,1,i]], {n,1,Length[coeffs]}]];






Table[x[[1]], {x,t1}]

Plot[Total[N[coeffs[[2924,1]]]*cheb],{t,-1,1}]




(* the Chebyshev polynomials for day n, axes ax, converted to Taylor *)
tocheb[n_, ax_] := Round[1000*CoefficientList[
 Total[coeffs[[Floor[n/ndays]+1,ax]]*cheb] /.
 t -> Mod[n,ndays]/ndays*2-1+t/ndays*2, t]]

final = Timing[Table[tocheb[n,ax],{n,1,Length[coeffs]*ndays-1},{ax,1,3}]];

(* max/min values tell us how much precision we need *)
(* the values of the nth coeff for the ax-th axis *)
coefflist[ax_,n_] := Table[final[[i,n,ax]],{i,1,Length[final]}];

N[Log[Max[%]-Min[%]]/Log[2]]

(* testing: can I pre-compute Chebyshev 32-day polynomials for speed? *)

test1[x_] = Sum[a[i]*ChebyshevT[i,x],{i,0,13}]

test2 = CoefficientList[test1[x/16-1],x]

(* for day 4, for example *)

test4[frac_] = CoefficientList[test1[(4+frac)/16-1],frac]

(* for day n *)

test5[n_, frac_] = CoefficientList[test1[(n+frac)/16-1],frac]

(* Given a list of Chebyshev coefficients (up to 14 coefficients =
order 13 polynomial), and n partitions, determine the Taylor (not
Chebyshev) coefficients for the m-th (0 <= m <= n-1 partition (for the
fractional part of m) *)

(* The a[i] below are dummy variables for efficiency *)

cheb2parttaylor[m_, n_] := cheb2parttaylor[m,n] =
 CoefficientList[Sum[a[i]*ChebyshevT[i-1,x], {i,1,14}] /. x->(m+frac)/n*2-1, 
frac]

cheb2parttaylor[0,8] /. a[i_] -> coeffs[[1,1,i]]








Flatten[final] >> /tmp/test1.m

(* testing below *)


f0[t_] = 
ArcTan[Total[tocheb[7323,2]*taylor]/Total[tocheb[7323,1]*taylor]]/Pi*12+12

(* fake arctan *)
arctan[x_] = x/(1+9/32*x^2)

(* fake pi *)
pi = Rationalize[Pi, 10^-12]

f1[t_] = ExpandDenominator[
ExpandNumerator[Together[ExpandAll[f0[t] /. {Pi -> pi, ArcTan -> arctan}]]]
]

f2[t_] = Normal[Series[f1[t],{t,0,3}]]

f3[t_] = Expand[Normal[Series[f0[t],{t,1/2,2}]]]



Sqrt[Expand[Total[tocheb[7323,1]*taylor]^2 + Total[tocheb[7323,2]*taylor]^2 + 
Total[tocheb[7323,3]*taylor]^2]]/149597870700

Total[tocheb[7323,2]*taylor]/Total[tocheb[7323,1]*taylor]

Plot[{ArcTan[x]-x/(1+.28125*x*x)},{x,-1,1}]
Plot[{ArcTan[x]-x/(1+28125/100000*x*x)},{x,-1,1}]


f1[t_] = Total[tocheb[7323,2]*taylor]/Total[tocheb[7323,1]*taylor]

f3[t_]=
ExpandNumerator[Together[ExpandAll[f1[t]/(1+28125/100000*f1[t]*f1[t])]]]/
12*Rationalize[Pi,10^-12]+24

f3[t_]= ExpandNumerator[ExpandDenominator[Together[ExpandAll[
f1[t]/(1+28125/100000*f1[t]^2)*12/Rationalize[Pi,10^-12]
]]]]






(* why not 28533/100000? becase it's not n/32? *)

f2[t_] = f1[t]/(1+28125/100000*Expand[Total[tocheb[7323,2]*taylor]^2]/
 Expand[Total[tocheb[7323,1]*taylor]^2])


Expand[f1[t]/(1+28125/100000*f1[t]*f1[t])]

err[r_] := NIntegrate[(ArcTan[x]-x/(1+r*x*x))^2,{x,-1,1}]








