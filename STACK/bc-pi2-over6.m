(* Demonstrates the sum of the 6th inverse powers for
http://math.stackexchange.com/questions/1747184/given-that-sum-frac1n2-frac-pi26-how-can-i-find-sum-frac1n
*)

(*

Recall the most basic power series:

$\frac{1}{1-x}=\sum _{i=0}^{\infty } x^i$

Integrating both sides:

$\int \frac{1}{1-x} \, dx=\sum _{i=0}^{\infty } \frac{x^{i+1}}{i+1}$

or:

$-\log (1-x) = \sum _{i=0}^{\infty } \frac{x^{i+1}}{i+1}$

By plugging in $x=0$, we see the constant of integration is 0, so I
omitted it above.

Dividing both sides by $x$ and integrating again:

$
   \int -\frac{\log (1-x)}{x} \, dx=\sum _{i=0}^{\infty }
    \frac{x^{i+1}}{(i+1)^2}
$

Note that we can't do these steps separately, since the intermediate
result would be undefined on both sides of the equality.

As noted in the comments, the left integral is the non-trivial polylog function: 







