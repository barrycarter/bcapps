(*

When adding nodes, give each new node the lowest possible color
number. A node's color is determined entirely by the nodes it is
connecting to, as below (binary)

*)

(* no subnodes, I get 1 *)

f[0] = 1;

(* 0001, I get 2 *)

f[1] = 2;

(* 0010, I get 1 *)

f[2] = 1;

(* 
