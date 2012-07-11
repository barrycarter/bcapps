(* Multiplication is repeated addition, and exponentiation is repeated
multiplication, kind of. Here, we explore going further using the
fundamental identity Log[x*y] = Log[x] + Log[y]. We use base 2, since
2+2 = 2*2 [it also equals 2^2, but that's irrelevant] *)

f0[x_,y_] = x + y

(* this is multiplication, but written in an unusual way *)
f1[x_,y_] = 2^(Log2[x] + Log2[y])

f2[x_,y_] = FullSimplify[2^(2^(Log2[Log2[x]]+Log2[Log2[y]]))]

(* this function repeated gives you addition in some sense *)
fn1[x_,y_] = Log2[2^x + 2^y]

