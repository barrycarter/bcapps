(*

Subject: Faster way to test possible points-to-plane-fitting identity?

Summary: I want to confirm an identity by checking that a certain sum
(provided near end of message) is 0 for all values of n>=3.

While attempting to solve
http://stats.stackexchange.com/questions/196655 (fitting points to a
plane), I came up with these (probably either wrong or previously
derived by someone else) formulas for `a,b,c` such that `z=a*x+b*y+c`
is a best fit for points n points `x[i], y[i], and z[i]`:

<pre><code>
a = 
-((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
   Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
   Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
   n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
   Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
   n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
  (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
   2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
   n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
    Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]))

b =
-((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
   Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
   Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
   n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
   Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
   n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
  (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
   2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
   n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
    Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]))

c =
(Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
  Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
  Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
  Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
  Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
  Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
 (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
  2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
  n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
   Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}])
</code></pre>

To confirm these values, I'd compute the sum of the differences
squared. Each term would look like this:

`diff[i_] = (z[i]-(a*x[i]+b*y[i]+c))^2`

Treating the sum as a function of `a,b,c`, I would take partials with
respect to these three variables and set equal to 0.

Since derivatives add, I would be adding the sum of the derivatives of
each term:

<pre><code>
derva[i_] = -2*x[i]*(-c - a*x[i] - b*y[i] + z[i])
dervb[i_] = -2*y[i]*(-c - a*x[i] - b*y[i] + z[i])
dervc[i_] = -2*(-c - a*x[i] - b*y[i] + z[i])
</code></pre>

and setting each sum equal to 0.

Mathematica won't solve that for arbitrary `n` (which I sort of expected):

<pre><code>
Solve[{
 Sum[derva[i],{i,1,n}] == 0,
 Sum[dervb[i],{i,1,n}] == 0,
 Sum[dervc[i],{i,1,n}] == 0
}, {a,b,c}]

Out[74] = {}
</code></pre>

and `Reduce` doesn't help either. Keeping the derivative outside the
sum doesn't work either, albeit with a different error message (the
standard `Solve::nsmet: This system cannot be solved with the methods
available to Solve.`).

Mathematica *will* solve for `a,b,c` for specific values of `n`, which
led me to the guess above.




agen = 
{-((-(xzs*ys^2) + n*xzs*yys - n*xys*yzs + xs*ys*yzs + xys*ys*zs - xs*yys*zs)/
   (n*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - n*xss*yys))}[[1]]

bgen = 
{-((-n*xys*xzs + xs*xzs*ys - xs^2*yzs + n*xss*yzs + xs*xys*zs - xss*ys*zs)/
   (n*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - n*xss*yys))}[[1]]

cgen = 
{(-(xys*xzs*ys) + xs*xzs*yys - xs*xys*yzs + xss*ys*yzs + xys^2*zs - 
xss*yys*zs)/(n*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - n*xss*yys)}[[1]]

sum = Sum[diff[i],{i,1,n}]

sumda = Sum[D[diff[i],a],{i,1,n}]
sumdb = Sum[D[diff[i],b],{i,1,n}]
sumdc = Sum[D[diff[i],c],{i,1,n}]

comps = {
 xs -> Sum[x[i],{i,1,n}],
 ys -> Sum[y[i],{i,1,n}],
 zs -> Sum[z[i],{i,1,n}],
 xss -> Sum[x[i]^2,{i,1,n}],
 yys -> Sum[y[i]^2,{i,1,n}],
 zzs -> Sum[z[i]^2,{i,1,n}],
 xys -> Sum[x[i]*y[i],{i,1,n}],
 xzs -> Sum[x[i]*z[i],{i,1,n}],
 yzs -> Sum[y[i]*z[i],{i,1,n}]
}

afin = agen /. comps
bfin = bgen /. comps
cfin = cgen /. comps

sumat = sumda /. {a -> afin, b -> bfin, c -> cfin}
sumbt = sumdb /. {a -> afin, b -> bfin, c -> cfin}
sumct = sumdc /. {a -> afin, b -> bfin, c -> cfin}



sol = Solve[{D[sum,a] == 0, D[sum,b] == 0, D[sum,c] ==0},{a,b,c}]
a0 = a /. sol;
b0 = b /. sol;
c0 = c /. sol;

simps = {
 Sum[x[i],{i,1,n0}] -> xs,
 Sum[y[i],{i,1,n0}] -> ys,
 Sum[z[i],{i,1,n0}] -> zs,
 Sum[x[i]^2,{i,1,n0}] -> xss,
 Sum[y[i]^2,{i,1,n0}] -> yys,
 Sum[z[i]^2,{i,1,n0}] -> zzs,
 Sum[x[i]*y[i],{i,1,n0}] -> xys,
 Sum[x[i]*z[i],{i,1,n0}] -> xzs,
 Sum[y[i]*z[i],{i,1,n0}] -> yzs
}

FullSimplify[a0 /. simps] /. simps

(*

solutions for various n0

n0 = 4

{-(((-4*ys^2 + 16*yys)*(-16*xzs + 4*xs*zs) - (16*xys - 4*xs*ys)*
     (-16*yzs + 4*ys*zs))/(-(-16*xys + 4*xs*ys)^2 + 
    (-4*xs^2 + 16*xss)*(-4*ys^2 + 16*yys)))}

n0 = 5

a:

{-((-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
     (-20*yzs + 4*ys*zs))/((-20*xys + 4*xs*ys)^2 - 
    (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))}

{-((-(xzs*ys^2) + 5*xzs*yys - 5*xys*yzs + xs*ys*yzs + xys*ys*zs - xs*yys*zs)/
   (5*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - 5*xss*yys))}


b:

{(20*xzs - 4*xs*zs + ((-4*xs^2 + 20*xss)*
     (-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
       (-20*yzs + 4*ys*zs)))/((-20*xys + 4*xs*ys)^2 - 
     (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))/(20*xys - 4*xs*ys)}

c:

{(zs + (ys*(-20*xzs + 4*xs*zs))/(20*xys - 4*xs*ys) + 
   ((xs - ((-4*xs^2 + 20*xss)*ys)/(20*xys - 4*xs*ys))*
     (-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
       (-20*yzs + 4*ys*zs)))/((-20*xys + 4*xs*ys)^2 - 
     (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))/5}

n0 = 6

{-((-((-4*ys^2 + 24*yys)*(-24*xzs + 4*xs*zs)) + (24*xys - 4*xs*ys)*
     (-24*yzs + 4*ys*zs))/((-24*xys + 4*xs*ys)^2 - 
    (-4*xs^2 + 24*xss)*(-4*ys^2 + 24*yys)))}

*)













