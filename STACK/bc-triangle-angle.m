(*
http://math.stackexchange.com/questions/1688586/finding-an-angle-in-a-triangle-when-the-length-of-one-side-is-unknown-and-the-d
*)

(*

Here's a purely analytical approach.

Use the triangle to define a complex number grid such that N is at the
origin (0 + 0I) and A is at positive real number `an`

We know B's distance from N (call it `bn`), we have:

Norm[b] == bn

TODO: verbosity

Norm[s] == ns
Norm[s-an] == as
Norm[s-bn] == bs

Solve[{
 Norm[s] == ns
 Norm[s-an] == as
 Norm[s-bn] == bs
}, s, Complexes]




*)
