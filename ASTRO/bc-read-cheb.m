(* given the output of bc-read-cheb.pl, a list of coefficients,
determine daily Taylor series to within 22m precision of Chebyshev
polynomials *)

(* day 0 = 1949-Dec-14 00:00:00.0000 UTC = JD 2433264.500000000 *)

(* 1970-01-01 = day 7323, 2014-01-01 = day 23394 *)

(* split coeffs into groups of ncoeff and then 3 axes *)

coeffs = Partition[Partition[coeffs,ncoeff],3];

(* function that semi-efficiently computes Taylor polynomial for
interval [a,b] treated as [0,1] where c[i] are the Chebyshev
coefficients up to order 14 (polynomial order 13) *)

cheb2tay[a_,b_] := cheb2tay[a,b] = 
CoefficientList[Sum[c[i+1]*ChebyshevT[i,x],{i,0,13}] /. x-> a+frac*(b-a),frac]

final = Round[1000*Flatten[Table[Table[Table[
cheb2tay[2*i/ndays-1, 2*(i+1)/ndays-1] /. 
 c[k_] -> coeffs[[l,j,k]], {j,1,3}], {i,0,ndays-1}], {l,1,Length[coeffs]}]]];

final >> /tmp/output.m

(* After we have the coefficients, test some stuff *)

coeffs = Partition[Partition[mercury,14],3];

(* find largest of each coefficient *)

t1 = Transpose[Partition[mercury,42]];

t2 = Table[Max[Abs[i]], {i,t1}]


