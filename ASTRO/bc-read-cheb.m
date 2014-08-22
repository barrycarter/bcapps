(* given the output of bc-read-cheb.pl, a list of coefficients,
determine daily Taylor series to within 10m precision of Chebyshev
polynomials *)

(* split coeffs into groups of 11 coefficients for Mars *)
coeffs = Partition[coeffs,11]

(* convert a list to a Chebyshev polynomial *)
tocheb[l_] := Function[x,
 Expand[Sum[l[[i]]*ChebyshevT[i-1,x],{i,1,Length[l]}]]]

(* convert to meters and ignore terms smaller than a meter *)
(* TODO: rounding before Taylor conversion = bad? *)
coeffs = Round[coeffs*1000]

