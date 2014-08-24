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
CoefficientList[Sum[c[i+1]*ChebyshevT[i,x],{i,0,ncoeff-1}] /. 
x-> a+frac*(b-a),frac]

final = Round[1000*Flatten[Table[Table[Table[
cheb2tay[2*i/ndays-1, 2*(i+1)/ndays-1] /. 
 c[k_] -> coeffs[[l,j,k]], {j,1,3}], {i,0,ndays-1}], {l,1,Length[coeffs]}]]];

final >> /tmp/output.m

(* After we have the coefficients, test some stuff *)

(* coeffs = Partition[Partition[moongeo,14],3]; *)

(* find largest of each coefficient *)

t1 = Transpose[Partition[moongeo,13*3]];

(* number of values we must store for each coefficient *)

t2 = Table[{i,1+Max[t1[[i]]]-Min[t1[[i]]]}, {i,1,Length[t1]}]

Table[Ceiling[Log[t2[[i,2]]]/Log[256]], {i,1,Length[t2]}]

Table[Ceiling[Log[t2[[i,2]]]/Log[2]], {i,1,Length[t2]}]

(* 76 bytes or 515 bits for mercury *)

(* 59 bytes or 379 bits for earthmoonbarycenter, same for moongeo *)

(* testing Fourier stuff below *)

test0 = Table[coeffs[[n,1,1]],{n,1,Length[coeffs]}];
test1 = Table[coeffs[[n,2,1]],{n,1,Length[coeffs]}];

(* testing with coeffs directly *)

test2 = Round[1000000*Transpose[Partition[coeffs,14*3]]];

test3 = Table[{i,1+Max[test2[[i]]]-Min[test2[[i]]]}, {i,1,Length[test2]}]
test3 = Table[{i,1+2*Max[Abs[test2[[i]]]]}, {i,1,Length[test2]}]


Table[Ceiling[Log[test3[[i,2]]]/Log[256]], {i,1,Length[test3]}]

Table[Ceiling[Log[test3[[i,2]]]/Log[2]], {i,1,Length[test3]}]

(* 122 bytes for mercury or 802 bits [for 8 days] *)


