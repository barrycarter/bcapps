(* computes A202259 in b-file form though 8 digits *)

(* not necessarily efficient or best way to do this *)

(* given a list, adds digits 0 to 9 to each member, creating list 10x as big *)

digitify[l_] := Flatten[Table[Range[i*10,i*10+9],{i,l}]]

(* the 1 digit members of A202259, excluding 0 *)
members[1] = {1, 4, 6, 8, 9};

(* n digit members must be n-1 digit members with a digit appended *)

tab[n_] := tab[n] = digitify[members[n-1]];

members[n_] := members[n] = Select[tab[n], !PrimeQ[#]&]

temp = Flatten[Table[members[n], {n,1,8}]];

(* i+1 below since I need to add '0' entry later *)

export = Table[ToString[i+1]<>" "<>ToString[temp[[i]]], {i,1,Length[temp]}];

(* add special case for 0 *)

export = Prepend[export, "1 0"];

Export["/tmp/temp.txt", export]

(* temp file was renamed and bzip2 compressed before githubing *)

