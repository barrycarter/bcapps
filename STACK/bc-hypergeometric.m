(*
http://stats.stackexchange.com/questions/210005/how-many-replications-to-eliminate-noise
*)

Although I upvoted @EngrStudent's comment, it turns out this is not a
simple problem, and I couldn't find an exact answer. The closest I came was:

https://www.jstor.org/stable/2347220

"Algorithm AS 145: Exact Distribution of the Largest Multinomial
Frequency", which provides an algorithm to compute the formula given
in the book "Combinatorial Chance":
https://en.wikipedia.org/wiki/Special:BookSources/9780852640579

What you have here is a multinomial distribution. As @EngrStudent
notes, adding the marbles 11-100 has no effect on the problem, so
let's consider selecting $n$ marbles (with replacement) from a bag
with $10 m$ marbles, with $m$ marbles labeled 1, $m$ marbles labeled
2, etc.

As $n$ grows large, we would expect $\frac{n}{10}$ marbles with each
number. However, some marbles will be chosen less frequently and some
marbles will be chosen more frequently.

One sample version of the question: for a given $k$, how large must
$n$ be to guarantee there's a 90% chance that each marble occurs
$\frac{n}{10}\pm k$ times.

Of course, we can replace 90% with a different probability, and talk
about $k$ as a percentage instead of an absolute number.

In general, we're asking: how far away from $\frac{n}{10}$ is the
frequency of the most or least frequently appearing marble (whichever
is further from $\frac{n}{10}$).

As https://en.wikipedia.org/wiki/Multinomial_distribution notes, the
distribution for a given marble has a mean of $\frac{n}{10}$ (in our
case) and a standard deviation of $\sqrt{n \frac{1}{10}
\frac{9}{10}}$.




TODO: mathoverflow

