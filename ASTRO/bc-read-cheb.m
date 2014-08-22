(* given the output of bc-read-cheb.pl, a list of coefficients,
determine daily Taylor series to within 22m precision of Chebyshev
polynomials *)

(* split coeffs into groups of 11 coefficients for Mars *)
coeffs = Partition[coeffs,11]

(* a "blank" Chebyshev polynomial list, from 0 to 10 *)
cheb = Table[ChebyshevT[i,t],{i,0,10}]

dayconv[n_,t_] = {Floor[n/32]+1, Mod[n,32]/16-1+t/32}


(* the Chebyshev polynomial for day n *)
tocheb[n_] := Expand[Total[coeffs[[Floor[n/32]+1]]*cheb] /. 
 t -> Mod[n,32]/16-1+t/16]





(* convert to meters and round, will round again later *)
coeffs = Round[coeffs*1000]

(* convert a list to a Chebyshev polynomial, get Taylor coeffs,
multiply by 1000, round *)

tocheb[l_] :=
Round[CoefficientList[Sum[l[[i]]*ChebyshevT[i-1,x],{i,1,Length[l]}],x]]

coeffs2 = Table[tocheb[i], {i,coeffs}]


