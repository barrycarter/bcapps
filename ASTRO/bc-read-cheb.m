(* given the output of bc-read-cheb.pl, a list of coefficients,
determine daily Taylor series to within 22m precision of Chebyshev
polynomials *)

(* day 0 = 1949-Dec-14 00:00:00.0000 UTC = JD 2433264.500000000 *)

(* number of coefficients per polynomial, number of days per polynomial *)

ncoeff = 11
ndays = 32

(* split coeffs into groups of ncoeff and then 3 axes *)

coeffs = Partition[Partition[coeffs,ncoeff],3]

(* "blank" Chebyshev polynomial list and Taylor series, from 0 to ncoeff-1 *)

cheb = Table[ChebyshevT[i,t],{i,0,ncoeff-1}]
taylor = Table[t^i,{i,0,ncoeff-1}]

(* the Chebyshev polynomials for day n, axes ax, converted to Taylor *)

tocheb[n_, ax_] := Round[1000*CoefficientList[
 Total[coeffs[[Floor[n/ndays]+1,ax]]*cheb] /.
 t -> Mod[n,ndays]/ndays*2-1+t/ndays*2, t]]

test[t_] = Total[tocheb[23394,1]*taylor]

t1 = Table[tocheb[n,1][[1]], {n,1,Length[coeffs]*ndays-1}]
t2 = Table[tocheb[n,1][[2]], {n,1,Length[coeffs]*ndays-1}]
t3 = Table[tocheb[n,1][[3]], {n,1,Length[coeffs]*ndays-1}]
t4 = Table[tocheb[n,1][[4]], {n,1,Length[coeffs]*ndays-1}]

