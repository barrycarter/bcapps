(*

Let's solve this problem by considering specific cases and then generalizing.

You want to know the distribution of V=X-Y, so let's consider a specific value of V, say 1.6

What values of X and Y make X-Y equal to 1.6? Let's be even more specific and make X = 0.5

Because X = 0.5, we have -0.5 < Y < 0.5, which means X-Y must be between 0 and 1 and thus never 1.6

In fact, for any value of X, -X < Y < X means that X-Y will be between 0 and 2X.

So, let's consider X=0.8 (the lowest possible value for which X-Y can be 1.6). If X=0.8, then X-Y=1.6 only if Y=-0.8.

[Pedantic note: -X < Y < X doesn't include the case Y=-X because it's a strict inequality; however, it turns out not to matter, since we're dealing with continuous distributions]

So what's the chance X=0.8 and Y=-0.8? Using the formula, that would be:

$\frac{1}{8} x (x-y)$

Substituting 0.8 for x and -0.8 for y, we get

$\frac{1}{8} 0.8 (0.8\, --0.8)$ which is 0.16

HoldForm[0.8 * (0.8 - -0.8)/8]

Of course, this doesn't mean the probability of X=0.8 and Y=-0.8 is 16%, since we're dealing with continuous distributions. It's just the contribution of X=0.8 and Y=-0.8 to the CDF of the probability X-Y=1.6

Now suppose X is an arbitrary value x (lower case), where x>0.8 (for the reason above) and x<2 (given in problem). For X-Y=1.6, we need:

$x-Y=1.6$ and thus $Y=x-1.6$

What's that probability that $Y=x-1.6$ (for a given x)? Using the formula and substituting x-1.6 for y, it's:

$\frac{1}{8} x (x-(x-1.6))$ which simplifies to $0.2 x$

Since we know x goes from 0.8 to 2, we now integrate:

$\int_{0.8}^2 0.2 x \, dx$ to get 0.336

Again, this doesn't mean the probability of V=1.6 is 33.6%, since V itself is a continuous distribution.

Now let's do the same thing for an arbitrary value of V. We know the limits of integration are $\frac{V}{2}$ and 2, and that we need:

$x-Y=v$ and thus $Y=x-v$

The PDF of this happening is:

$\frac{1}{8} x (x-(x-v))$ or $\frac{v x}{8}$

We now integrate

$\int_{\frac{v}{2}}^2 \frac{v x}{8} \, dx$

to get $\frac{v}{4}-\frac{v^3}{64}$, the final answer.

Since I've solved the problem completely, you might want to find the distribution for X+Y or X*Y or even X/Y to test your understanding.
