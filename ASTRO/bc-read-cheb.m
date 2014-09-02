(* given the output of bc-read-cheb.pl, a list of Chebyshev
coefficients, determine Taylor series for 4 day intervals to within
1mm of theoretical precision; choosing 4 day intervals because that's
the smallest interval used *)

(* day 0 = 1949-Dec-14 00:00:00.0000 UTC = JD 2433264.500000000 *)

(* 1970-01-01 = day 7323, 2014-01-01 = day 23394 *)

(* 1970-01-02 = chunk 1831, 2014-01-03 = chunk 5849 *)

(* 

Semi-efficiently convert Chebyshev polynomials to Taylor series
expansion for n coefficients (polynomial degree n-1), where c[i] are
the Chebyshev coefficients (c[0] is the constant term).

TODO: Should be a better way of doing this than using c[i]

*)

cheb2tay[n_] := cheb2tay[n] = 
 CoefficientList[Sum[c[i]*ChebyshevT[i,x],{i,0,n-1}],x]

(* the multiplier; we store each coeff to 1/this number km *)

mult = 32768;

(* split coeffs into groups of ncoeff *)

coeffs = Partition[coeffs,ncoeff];

(* convert integer to bit string of given length n, allowing for
special cases and adding 2^(n-1) to negative numbers; this effectively
makes the high bit a sign bit *)

int2bit[int_,n_] = If[n==0,{}, IntegerDigits[int+2^(n-1),2,n]]

final = Flatten[Round[32768*Table[cheb2tay[ncoeff] /. c[i_] :> coeffs[[n,i+1]],
{n,1,Length[coeffs]}]]];

(* below is test only *)

test0 = Sum[coeffs[[172,i]]*ChebyshevT[i-1,t],{i,1,Length[coeffs[[172]]]}]
test1 = Sum[final[[172,i]]*t^(i-1),{i,1,Length[final[[172]]]}]
Plot[test0-test1/32768,{t,-1,1}]

(* find largest of each coefficient, and how many bits to store it *)

t1 = Transpose[Partition[final,ncoeff*3]];
t2 = Table[{i,1+2*Max[Abs[t1[[i]]]]}, {i,1,Length[t1]}]
t3 = Table[Ceiling[Log[t2[[i,2]]]/Log[2]], {i,1,Length[t2]}]

(* this number is constant across the lists, the number of coefficients *)

nperlist = Length[t1[[1]]];

t4 =Table[int2bit[t1[[j,i]],t3[[j]]], {i,1,nperlist}, {j,1,Length[t1]}];

t5 = Partition[Flatten[Transpose[t4]],8];

t6 = Table[FromDigits[i,2],{i,t5}];

t3 >> /tmp/output-precision.m
t6 >> /tmp/output-data.m

Exit[];

(* everything below this line is testing *)

(* To convert above to true binary (note there is no -l below):

perl -ne 'while (s/(\d+)//) {print chr($1);}' /tmp/output.m > whatever

*)

(* After we have the coefficients, test some stuff *)

(* coeffs = Partition[Partition[moongeo,14],3]; *)

(* number of values we must store for each coefficient *)

t2 = Table[{i,1+Max[t1[[i]]]-Min[t1[[i]]]}, {i,1,Length[t1]}]

Table[Ceiling[Log[t2[[i,2]]]/Log[256]], {i,1,Length[t2]}]


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

Plot[{superfour[t1[[1]],1][x],t1[[1,Floor[x]]]},{x,1,Length[t1[[1]]]}]

Plot[{superfour[t1[[1]],1][x],t1[[1,Floor[x]]],
superfour[t1[[1]],1][x]-t1[[1,Floor[x]]]},{x,1,Length[t1[[1]]]}]

f0[x_] = a+b*Cos[c*x-d] /. FindFit[t1[[1]], a+b*Cos[c*x-d], {a,b,c,d}, x]

l0 = Table[f0[x]-t1[[1,x]],{x,1,Length[t1[[1]]]}];

f1[x_] = a+b*Cos[c*x-d] /. FindFit[l0, a+b*Cos[c*x-d], {a,b,c,d}, x]

l1 = Table[f1[x]-l0[[x]],{x,1,Length[l0]}];

f0[x_] = a+b*Cos[c*x-d] /. FindFit[t1[[1]], a+b*Cos[c*x-d], 
 {a,{b,1.84*10^12},{c,.28},{d,1}}, x]


