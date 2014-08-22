(* given the output of bc-read-cheb.pl, a list of coefficients,
determine daily Taylor series to within 22m precision of Chebyshev
polynomials *)

(* given time t (fraction of a day) on the nth day, convert to list
and point on Chebyshev polynomial *)

tolist[n_, t_] = (t+n)/32+1

(* convert to meters and round, will round again later *)
coeffs = Round[coeffs*1000]

(* split coeffs into groups of 11 coefficients for Mars *)
coeffs = Partition[coeffs,11]

(* convert a list to a Chebyshev polynomial, get Taylor coeffs,
multiply by 1000, round *)

tocheb[l_] :=
Round[CoefficientList[Sum[l[[i]]*ChebyshevT[i-1,x],{i,1,Length[l]}],x]]

coeffs2 = Table[tocheb[i], {i,coeffs}]


