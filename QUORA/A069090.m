(* computes A069090 in b-file form though 8 digits *)

(* not necessarily efficient or best way to do this *)

(* 

We start with A202259, since all members of A069090 with more than
1 digit must contain a member of A202259 as a prefix

See https://github.com/barrycarter/bcapps/blob/master/QUORA/ for
A202259.b.txt.bz2 used below

*)

a202259 = 
 Transpose[ReadList["!bzcat A202259.b.txt.bz2", {Number, Number}]][[2]];

(* since we want 8 digit members of A069090, we only need 7 digit
members of A202259; on my machine, attempting to generate 9 digit
members of A069090 runs out of memory *)

a202259 = Select[a202259, # < 10^7 &];


(* given a list, adds digits 0 to 9 to each member, creating list 10x as big *)

digitify[l_] := Flatten[Table[Range[i*10,i*10+9],{i,l}]]

(* if the results are prime, we have a member of A069090 *)

a069090 = Select[digitify[a202259], PrimeQ];

export=Table[ToString[i]<>" "<>ToString[a069090[[i]]], {i,1,Length[a069090]}];

Export["/tmp/temp.txt", export]

(* temp file was renamed and bzip2 compressed before githubing *)


