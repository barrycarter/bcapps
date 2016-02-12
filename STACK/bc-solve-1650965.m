(*

Induction: give each new node the lowest number possible.

In this case, a node with number 'n' must have a given subset of nodes:

If a node is numbered 4, it must have children with numbers 1, 2, 3.

This is subset 7 (2^2 + 2 + 1)

f[4] = {7}

If numbered 3, childset must be {1,2} or {1,2,4}

f[3] = {3, 11}

IF 2, {{1},{1,3},{1,4},{1,3,4}}

f[2] = {1, 5, 9, 13}

If 1, {{2}, {3}, {4}, {2,3}, {2,4}, {3,4}, {2,3,4}}

f[1] = {2,4,8,6,10,12,14}

*)
