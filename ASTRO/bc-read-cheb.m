(* Given a list of Chebyshev coefficients (coeffs) for a given planet,
and the number of coefficients (ncoeff) per polynomial, convert to
Taylor coefficients, round both to the nearest 1/32768 km, and output
the new lists in a highly-compressed format *)

(* day 0 = 1949-Dec-14 00:00:00.0000 UTC = JD 2433264.500000000 *)
(* 1970-01-01 = day 7323, 2014-01-01 = day 23394 *)
(* 1970-01-02 = chunk 1831, 2014-01-03 = chunk 5849 *)

(* convert integer to bit string of given length n, allowing for
special cases and adding 2^(n-1) to negative numbers *)

int2bit[int_,n_] = If[n==0,{}, IntegerDigits[int+2^(n-1),2,n]]

(* convert a list of Chebyshev coefficients to a list of Taylor
coefficients; this version might be less efficient than the earlier
one, but works fast enough for me *)

cheb2tay[x_] := CoefficientList[Sum[
 x[[i]]*ChebyshevT[i-1,t], {i,1,Length[x]}],t];

(* the multiplier; we store each coeff to 1/this number km *)

mult = 32768;

(* Round the coefficients to the nearest 1/mult *)

rcoeff = Round[coeffs*mult];

(* how many bits do we need to store each coefficent? *)

nbits = Table[
Ceiling[Log[1+2*Max[
 Abs[Transpose[Partition[rcoeff, ncoeff*3]][[i]]]]
]/Log[2]], {i,1,ncoeff*3}];

(* convert coefficients to binary format, and group in 8 bit sets *)

bits = Partition[
 Flatten[Table[int2bit[rcoeff[[i]], nbits[[1+Mod[i-1,Length[nbits]]]]],
 {i,1,Length[rcoeff]}]],8];

(* convert to 8-byte numbers *)

bytes = Table[FromDigits[i,2], {i,bits}];

(* output bytes (we will re-use variables for Taylor below) *)

nbits >> /tmp/bc-read-cheb-output-bits.txt;
bytes >> /tmp/bc-read-cheb-output.txt;

Print["nbits_cheb=",nbits // FullForm];
Print["bytes_cheb=",bytes // FullForm];

(* now, the same thing for Taylor converted coefficients (we convert
from the pure numbers, not the rounded numbers, then multiply and round) *)

rcoeff=Flatten[Round[Table[cheb2tay[i], {i,Partition[coeffs, ncoeff]}]*mult]];

nbits = Table[
Ceiling[Log[1+2*Max[
 Abs[Transpose[Partition[rcoeff, ncoeff*3]][[i]]]]
]/Log[2]], {i,1,ncoeff*3}];

bits = Partition[
 Flatten[Table[int2bit[rcoeff[[i]], nbits[[1+Mod[i-1,Length[nbits]]]]],
 {i,1,Length[rcoeff]}]],8];

bytes = Table[FromDigits[i,2], {i,bits}];

nbits >> /tmp/bc-read-taylor-output-bits.txt;
bytes >> /tmp/bc-read-taylor-output.txt;

Print["nbits_tay=",nbits // FullForm];
Print["bytes_tay=",bytes // FullForm];

Exit[];
