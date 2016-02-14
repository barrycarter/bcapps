(*

When adding nodes, give each new node the lowest possible color
number. A node's color is determined entirely by the nodes it is
connecting to, as below (binary)

*)

(* if my child nodelist is xxx0 [ie, the even numbers], I get 1 *)

s1 = {0, 2, 4, 6, 8, 10, 12, 14}

(* if my child nodelist is xx01, I get 2; 0001, 0101, 1001, 1101 *)

s2 = {1, 5, 9, 13}

(* if my child nodelist is x011, I get 3; 0011 1011 *)

s3 = {3, 11}

(* if my child nodelist is 0111, I get 4 *)

s4 = {7}

(* if my child nodelist is 1111, abort *)

f[15] = Null;

Table[f[i] = 1, {i,s1}]
Table[f[i] = 2, {i,s2}]
Table[f[i] = 3, {i,s3}]
Table[f[i] = 4, {i,s4}]

(* and the quasi-inverse *)

g[i_] := g[i] = Select[Range[0,14], f[#] == i &]
{g[1],g[2],g[3],g[4]}

inv[list_] := Flatten[Map[g,list]]


