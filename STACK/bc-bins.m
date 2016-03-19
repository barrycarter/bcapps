(*

http://math.stackexchange.com/questions/1704152/throwing-balls-into-bins-where-some-of-the-bins-are-closed-after-one-ball

When you throw a ball, there are three non-equal possibilities:

  - You hit an empty one-ball bin that then closes.

  - You hit an empty regular bin.

  - You hit a regular bin that has >=1 balls in it already.

If there are r empty one ball bins, s empty regular bins and t
non-empty regular bins, the probabilities above are $\frac{r}{r+s+t}$,
$\frac{s}{r+s+t}$, and $\frac{t}{r+s+t}$ respectively.

rst values then next step: r-1,s,t or r-1,s-1,t or r,s,t

a[r_,s_,t_] = r/(r+s+t)*a[r-1,s,t] + s/(r+s+t)*a[r,s-1,t] + t/(r+s+t)*a[r,s,t]

RSolve[
 a[r,s,t] == r/(r+s+t)*a[r-1,s,t] + s/(r+s+t)*a[r,s-1,t] + t/(r+s+t)*a[r,s,t],
 a[r,s,t], {r,s,t}
]

Concrete: 7 total, 4 one-ball, 3 regular

a[4,3,0] = 1

a[r_,s_,t_] := 0 /; r<0||s<0||t<0

a[r_,s_,t_] := a[r,s,t] = 
 r/(r+s+t)*a[r-1,s,t] + s/(r+s+t)*a[r,s-1,t] + t/(r+s+t)*a[r,s,t]

