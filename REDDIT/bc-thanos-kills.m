Subject: Randomly choose 50% of n things, but only 1% of specific k things implies what?

Summary: If you randomly choose 50% of n entities total, but it turns out you only chose 1% of k specific pre-chosen entities, does that imply n is likely to be much larger than k?

I'm trying to use Mathematica to solve https://www.reddit.com/r/answers/comments/9hcvk0/if_thanos_destroys_half_the_population_of_the/ using Bayesian analysis, but hit a brick wall

Statement of problem: If Thanos destroys half the population of the universe, with individuals chosen completely at random, but only 1% of the population of Earth is destroyed, what exactly would that mean? Would that imply that Earth only makes up for a tiny fraction of the population of the universe?

My claims:

  - The chance that only 1% Earth population destroyed is constant, since it only depends on the Earth population. It's `Binomial[k,k/100]*(1/2)^(k/100)*(1/2)^(k-k/100)` which simplifies to `Binomial[k, k/100]/2^k`.

  - If only 1% of the Earth population is destroyed, it is more likely the universe is larger.

  - The claims above do not conflict.

The first claim seems trivial, here's my work on the second claim:

<pre><code>

(*

n = number of people in the universe including Earth
k = number of people on Earth

Note that k is a known number (about 8 billion), but I am generalizing to any k

We now select k/100 people from the k people on Earth and the
remaining n/2-k/100 people from the n-k people not on Earth.

Since the total ways of selecting people is 2^n, the probability our
selection matches the criteria is:

*)

f[n_, k_] = Binomial[k, k/100]*Binomial[n-k, n/2-k/100]/2^n

(*

Note that our problem requires that:

  - k is a multiple of 100
  - n is even
  - n > 99*k/50

I'm not completely happy with this formulation because it implies
exactly 1% of Earth's population is destroyed, instead of "less than
1%" or "approximately 1%". The fact that we're specifying an exact
number seems wrong (for one thing, as above, it requires the
population of Earth be an exact multiple of 100). However, I'll go
with it for the moment.

The smallest numbers that work are k=100 and n=198 for which we have:

f[198,100] == 25/100433627766186892221372630771322662657637687111424552206336

If we bump n to 200 (it has to be even), we get:

f[200,100] == 625/100433627766186892221372630771322662657637687111424552206336

Dividing the two:

f[200,100]/f[198,100] == 25

seems to show it's 25 times more likely that our condition will be met
if n=200 than if n=198.

Continuing along these lines:

N[Table[f[n,100]/f[198,100], {n, 198, 210, 2}]] ==
 {1., 25., 321.938, 2845.38, 19405., 108857., 522913.}

shows that the larger n is, the more likely our conditions are met for
k fixed at 100.

To find the absolute probability than n=198 (for example), we'd want:

f[198,100]/Sum[f[n,100], {n, 198, Infinity, 2}]

but this yields "Sum::div: Sum does not converge.", somewhat as
expected since f[n,k] grows with n

This makes me suspicious that my Bayesian analysis isn't accurate.

However, if we break our n population into groups of k, the percentage
of people killed in each group is distributed almost normally
(essentially normally for large n) with a mean of k/2 and a variance
of k/4 (thus a standard deviation of Sqrt[k]/2). The more groups there
are, the more likely it is there will be at least one group that has
only 1% of the population killed.

However however, I don't think this argument can be applied to a
*specific* group of k people.

Thoughts?

*)

</code></pre>
