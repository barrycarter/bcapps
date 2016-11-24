(* http://math.stackexchange.com/questions/2028308/how-to-determine-the-average-number-of-dice-showing-the-most-common-value *)

(* rolling 8d6 = 1679616 *)

<<Combinatorica`

d = {1,2,3,4,5,6};

x = Tuples[d,6];

counts = Table[Max[BinCounts[i]], {i, x}];

BinCounts[counts]

