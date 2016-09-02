(*

https://www.quora.com/How-do-you-find-the-uncertainty-in-a-measurement-of-the-probability-of-a-Bernoulli-trial-calculated-from-doing-it-repeatedly-and-using-success-trials

Subject: Getting to First Bayesian

Suppose a baseball team has a fixed probablity p of winning a game [1], and has won 14 of their previous 20 games. What can you say about p?

Your best guess for p would be 0.70. If p actually were 0.70, their chance of winning exactly 14 out of 20 games would be:

[math]\binom{20}{14} 0.7^{14} 0.3^6 \approx 0.1916[/math]

What is p were 0.55? Then their chance of winning exactly 14 out of 20 games would be:

[math]\binom{20}{14} 0.55^{14} 0.45^6 \approx 0.0746[/math]

In other words, it's about 2.5 times more likely ([math]\frac{0.1916}{0.0746}[/math]) that p is 0.70 rather than 0.55

The chance of winning 14 out of 20 games for a given value p is: [math]\binom{20}{14} p^{14} (1-p)^6[/math]

If we have n trials with k successes (here, n=20 and k=14), the probablity is [math]\binom{n}{k} p^k (1-p)^{n-k}[/math].

Let's graph this for our case (14 wins out of 20 games):

[[image17.gif]]

This looks a lot like a probability distribution function (PDF), except that it integrates out to [math]\frac{1}{21}[/math]. We can turn it into an actual PDF by multiplying by 21: [math]21 \binom{20}{14} p^{14} (1-p)^6[/math]

In the general case, we multiply by n+1, and the PDF becomes: [math](n+1) p^k \binom{n}{k} (1-p)^{n-k}[/math]

We know the mode of this PDF is [math]\frac{14}{20}[/math] or [math]\frac{k}{n}[/math], but let's also find the mean and the standard deviation.

To compute the mean, we integrate:

[math]\int_0^1 p (n+1) p^k \binom{n}{k} (1-p)^{n-k} \, dp[/math]

which turns out to be [math]\frac{k+1}{n+2}[/math], a well known result from Bayesian analysis. In our case, this is [math]\frac{15}{22}[/math].

To find the variance, we integrate:



conds = {Element[{n,k}, Integers], k > 0, n >= k, x >= 0, x <= 1, p>=0, p<=1}



TODO: median badness

TODO: change into PDF!

We clearly see than the mode is [math]\frac{14}{20}[/math] here, or [math]\frac{k}{n}[/math] in general.

To compute the median:

Integrate[f[p,k,n],{p,0,x}]

f[p_,k_,n_] = Binomial[n,k]*p^k*(1-p)^(n-k)

pdf[p_,k_,n_] = Binomial[n,k]*p^k*(1-p)^(n-k)*(n+1)

mean[p_,k_,n_] = (k+1)/(n+2);

pdf[p,k,n]*(p-mean[p,k,n])^2

((1 + k)*(1 - k + n))/((2 + n)^2*(3 + n))

pdf[p,k,n]*(HoldForm[p]-mean[p,k,n])^2


$\int_0^1 (n+1) p^k \binom{n}{k} (1-p)^{n-k} \left(p-\frac{k+1}{n+2}\right)^2 \, dp$



p0 = Plot[f[p,14,20],{p,0,1}, Frame -> {True, True, False, False}, 
 RotateLabel -> True, AxesOrigin-> {0,0}, FrameLabel -> {
 Text[Style["If p is ...", FontSize->25]], 
 Text[Style["Chance of winning 14/20 is...", FontSize->25]]
}]
showit



FullSimplify[Integrate[f[p,k,n],{p,0,x}], conds]

Beta[x, 1 + k, 1 - k + n] Binomial[n, k]

Solve[Beta[x, 1 + k, 1 - k + n] Binomial[n, k] == 1/2, x]



f[p_,k_,n_] = Binomial[n,k]*p^k*(1-p)^(n-k)









[1] This is highly unrealistic, since baseball teams play different opponents under different conditions at different times. However, if I said "Bernoulli trial", I'd lose even more readers than by saying "baseball".

https://www.quora.com/If-someone-makes-multiple-predictions-that-events-will-occur-with-x-likelihood-but-they-all-occur-what-can-we-say-about-those-predictions

I found this problem fascinating, and dug into it a bit.

When you predict that the probability is 70%, what are you actually saying? The most obvious interpretation is that the team will win exactly 14 of its next 20 games.

Even if you're absolutely right about the 70%, the chance of that happening is:

[math]\binom{20}{14} 0.7^{14} 0.3^6 \approx 0.1916[/math]

In other words, even if you are 100% correct about the probability, there is a better than 80% chance that the team won't win exactly 14 games.

This isn't really that surprising. If you toss a fair coin 1000 times, the chance you will get *exactly* 500 heads and *exactly* 500 tails is low. Instead, you would expect to get *roughly* 500 heads and *roughly* 500 tails.

OK, how about the chance of winning 14 games give or take one game?

[math]\binom{20}{13} 0.7^{13} 0.3^7 \approx 0.1643[/math]
[math]\binom{20}{15} 0.7^{15} 0.3^5 \approx 0.1788[/math]

Adding these numbers up, you get 0.5348. In other words, when you say the probability of a win is 70%, you're saying there's a better than 1 in 2 chance that the team will win between 13 and 15 games.

Using similar calculations, you're saying there's a 97.52% chance they'll win between 10 and 18 games, and a 99.41% chance they'll win between 9 and 19 games. In other words, when the team wins 20 games in a row, it's strong evidence that your 70% estimate was probably incorrect.

I'd really like to do more here, because answering the question "how do you determine if a probabilistic guess is 'correct'" is an interesting one. Although I'm guessing it has been studied, I want to look into it more.


TODO: more here

TODO: usually reverse null hypo, compare to 50%?

TODO: (k+1)/(n+2)


*)

chance[n_] = Binomial[20,n]*0.7^n*0.3^(20-n)

Sum[chance[14+n],{n,-2,2}]





