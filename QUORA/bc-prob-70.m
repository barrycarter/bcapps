(*

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

TODO: usually reverse null hypo, compare to 50%?

TODO: (k+1)/(n+2)


*)

chance[n_] = Binomial[20,n]*0.7^n*0.3^(20-n)

Sum[chance[14+n],{n,-2,2}]





