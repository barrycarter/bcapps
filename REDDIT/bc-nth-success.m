(*

This is just to add to @Dougal's excellent and correct answer and to answer https://www.reddit.com/r/askscience/comments/5k1fmb/whats_the_average_number_of_attempts_necessary_to/ (heavily edited):

<blockquote>
Given a 1% chance of success in a Bernoulli trial, we solve `.99x = .5` to find it will take ~68 attempts before the cumulative chance of 1 success exceeds 1/2.

How many attempts will it take for the chance of 1000 successes to exceed 1/2?

</blockquote>

%% TODO: use trial and attempt consistently

First, some answers to the specific question above:

  - If you repeat the trial many times, count the number of attempts until you reach 1000 success each time, and average the results, you will get 100000. This is the "mean" of the distribution, and has the value you'd pretty much expect: if you have a 1% chance of success, it should take 1000/(1%) or 100000 attempts to get 1000 successes.

  - Your chances of getting 1000 successes on or before the 99666th attempt is about 0.499957

  - Your chance of getting your 1000th success on exactly the 99667th attempt is about 0.000126817

  - Therefore, your chances of getting 1000 successes on or before the 99667th attempt is 0.500084

  - Thus, the "average" *you* seek is 99666 or 99667, depending on whether you're looking for a chance of just under or just over 50%. This is called the "median".

  - You are most likely to get the 1000th success on exactly the 99900th or 99901st attempt. The probability of getting the 1000th success on one of these attempts is 0.00012684504 each (0.00025369 total). This is the "mode".

  - However, the chances of getting the 1000th success on exactly the 99899th or 99902nd attempts are only slightly smaller: 0.0001268450282 each.

  - The likelihood of getting the 1000th success on exactly the nth attempt:

[[image1.gif]]

Of course, the function above is only defined for integers, but I've extended it to all real numbers (see general discussion below for details) to make graphing easier.

The bell-shaped curve above looks a lot like the normal distribution, and can, in fact, be approximated by the normal distribution with a mean of 100000 and a variance of 9900000 (standard deviation of ~3146.43):

[[image2.gif]]

The approximation above is so close that the graphs actually overlap. However, we know the approximation can't be exact, since the normal distribution has the same mean, mode, and median, whereas the distribution we're looking at (which happens to be the negative binomial distribution) has three different numbers for mean, mode, and median.

We can see the differences by zooming in close to 100000:

[[image3.gif]]

We can improve this approximation slightly by moving the center of the normal distribution from the mean of our distribution (100000) to the mode (99900.5):

[[image4.gif]]

However, we see that even this approximation is not exact (as we know it can't be), this time by looking at the values near 94500 and 105500:

[[image5.gif]]

[[image6.gif]]

# General Discussion #

What are the chances that our kth success will occur on exactly the nth attempt (with a probability p for each success)?

This would mean we've had k-1 successes in the first n-1 attempts, followed by a success on our nth attempt. We use the binomial theorem to find the chance of k-1 successes in n-1 attempts (and thus (n-1)-(k-1) or n-k failures):






**NEGBIN link 


Plot[
 {s1[1000,n,1/100], PDF[NormalDistribution[99900.5,Sqrt[9900000]]][n]},
 {n,94000,95000}, PlotRange -> All,
 PlotLegends -> {"actual", "normal"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Probability", None}, {"n (attempt number)", None}},
 PlotLabel -> 
"Probability of 1000th success on exactly nth attempt\n(p=0.01 per attempt)"
]

Plot[
 {s1[1000,n,1/100], PDF[NormalDistribution[99900.5,Sqrt[9900000]]][n]},
 {n,94000,106000}, PlotRange -> All,
 PlotLegends -> {"actual", "normal"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Probability", None}, {"n (attempt number)", None}},
 PlotLabel -> 
"Probability of 1000th success on exactly nth attempt\n(p=0.01 per attempt)"
]

Plot[
 {s1[1000,n,1/100], PDF[NormalDistribution[99900.5,Sqrt[9900000]]][n]},
 {n,99500,100500}, PlotRange -> All,
 PlotLegends -> {"actual", "normal"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Probability", None}, {"n (attempt number)", None}},
 PlotLabel -> 
"Probability of 1000th success on exactly nth attempt\n(p=0.01 per attempt)"
]

Plot[
 {s1[1000,n,1/100], PDF[NormalDistribution[99900.5,Sqrt[9900000]]][n]},
 {n,99000,101000}, PlotRange -> All,
 PlotLegends -> {"actual", "normal"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Probability", None}, {"n (attempt number)", None}},
 PlotLabel -> 
"Probability of 1000th success on exactly nth attempt\n(p=0.01 per attempt)"
]




However, if we zoom in close to 100000, we 

Plot[
 {s1[1000,n,1/100], PDF[NormalDistribution[100000,Sqrt[9900000]]][n]},
 {n,99000,101000}, PlotRange -> All,
 PlotLegends -> {"actual", "normal"},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Probability", None}, {"n (attempt number)", None}},
 PlotLabel -> 
"Probability of 1000th success on exactly nth attempt\n(p=0.01 per attempt)"
]



TODO: mention this file!



TODO: disclaim nonintegral!, n<1000

Plot[{s1[1000,n,1/100]},{n,0,200000}, PlotRange -> All,
 PlotLegends -> {},
 Frame -> { {True, False}, {True, False}},
 FrameLabel -> { {"Probability", None}, {"n (attempt number)", None}},
 PlotLabel -> 
"Probability of 1000th success on exactly nth attempt (p=0.01 per attempt)"
]
 
Newtonian vs Relativistic Constant Acceleration\n(v(0) = 0.1, a = 0.002)"]





TODO: 99666.


(*

https://www.reddit.com/r/askscience/comments/5k1fmb/whats_the_average_number_of_attempts_necessary_to/

http://stats.stackexchange.com/questions/111257/probability-of-k-successes-in-no-more-than-n-bernoulli-trials

*)

(* 3rd success on attempt 5 *)

Binomial[4,2]*p^3*(1-p)^2

(* 3rd success on attempt n *)

Binomial[n-1,2]*p^3*(1-p)^(n-3)

(* 3rd success on or before attempt n *)

Sum[Binomial[i-1,2]*p^3*(1-p)^(i-3),{i,0,n}]

(* kth success on attempt n *)

s1[k_,n_,p_] = Binomial[n-1,k-1]*p^k*(1-p)^(n-k)

(* binomial as gamma *)

binomial[n_,k_] = n!/k!/(n-k)! /. x_! -> Gamma[x+1]

(* using gamma functions *)

s2[k_,n_,p_] = s1[k,n,p] /. Binomial[n_,k_] -> binomial[n,k]

(* cumulatives *)

cs1[k_,n_,p_] = Sum[s1[k,i,p],{i,k,n}]

cs2[k_,n_,p_] = Sum[s2[k,i,p],{i,k,n}]

(* they do add to 1 *)

Sum[s1[k,i,p], {i,k,Infinity}]
Sum[s2[k,i,p], {i,k,Infinity}]

(* mean is k/p *)

Sum[i*s1[k,i,p], {i,k,Infinity}]

FullSimplify[Sum[i*s2[k,i,p], {i,k,Infinity}]]

(* variance is k*(1-p)/p^2 but below doesnt give it *)

Sum[(s1[k,i,p]-k/p)^2, {i,k,Infinity}]

(* skewness (2-p)/Sqrt[k*(1-p)] *)

(* kurtosis 3 + (6 - 6*p + p^2)/(k*(1 - p)) *)

Plot[s1[1000,i,1/100],{i,0,200000}, PlotRange -> All]

PDF[NormalDistribution[1000/(1/100), Sqrt[1000*(99/100)*100^2]]][x]

Plot[{
 PDF[NormalDistribution[1000/(1/100), Sqrt[1000*(99/100)*100^2]]][x],
 s1[1000,x,1/100]}, {x,0,200000}, PlotRange -> All] 


cs[k_,n_,p_] = Sum[s[k,i,p],{i,k,n}]

Table[{1000*i,cs[1000,1000*i,1/100]}, {i,1,100}];

Table[{i,cs[1000,i,1/100]}, {i,99000,100000,100}];

Table[{i,cs[1000,i,1/100]}, {i,99900,100000,1}];

Table[{i,cs[1000,i,1/100]}, {i,1000,100000,1000}];

t1857 = Table[{i,cs[1000,i,1/100]}, {i,1000,110000,1000}];

t1859 = Table[{i,cs[1000,i,1/100]}, {i,90000,110000,100}];

Plot[s[1000,i,1/100],{i,1000,200000}, PlotRange -> All]

Integrate[s[1000,i,1/100],{i,1000,n}]

nd[x_] = PDF[NormalDistribution[100000, Sqrt[100000*1/100*99/100]]][x]

nd2[x_] = PDF[NormalDistribution[100000, 10*Sqrt[100000*99/100]]][x]

nd3[x_] = PDF[NormalDistribution[100000, Sqrt[100000*100]]][x]

Plot[{s[1000,i,1/100], nd[i]},{i,1000,200000}, PlotRange -> All]

Plot[{s[1000,i,1/100],nd2[i]},{i,90000,110000}, PlotRange -> All]

Plot[{s[1000,i,1/100]-nd2[i]},{i,90000,110000}, PlotRange -> All]

Plot[{s[1000,i,1/100]-nd2[i]},{i,0,200000}, PlotRange -> All]

Plot[{s[1000,i,1/100]/nd2[i]},{i,0,200000}, PlotRange -> All]

Plot[{s[1000,i,1/100]-nd3[i]},{i,0,200000}, PlotRange -> All]

Plot[{s[500,i,1/2]},{i,500,2000}, PlotRange -> All]

norm[u_,sd_,x_] = PDF[NormalDistribution[u,sd]][x]

Plot[{s[500,i,1/2], norm[1000, Sqrt[500/4], i]},{i,500,2000}, PlotRange -> All]

Plot[{s[500,i,1/2], norm[1000,Sqrt[2*500],i]},{i,500,2000}, PlotRange -> All]

Plot[{s[500,i,1/2]-norm[1000,Sqrt[2*500],i]},{i,500,2000}, PlotRange -> All]

Plot[{s[500,i,1/3]},{i,1000,2000}, PlotRange -> All]

Integrate[t^(a-1)*(1-t)^(b-1),{t,0,x}]

Beta[x,a,b]

Binomial[n,k]

n! -> Gamma[n+1]


s[k_,n_,p_] = binomial[n-1,k-1]*p^k*(1-p)^(n-k)

cs[k_,n_,p_] = Sum[s[k,i,p],{i,k,n}]

Simplify[PDF[NegativeBinomialDistribution[n,p]][x],x>0]

Simplify[PDF[NegativeBinomialDistribution[k,p]][n-k],n>k]

Simplify[PDF[NegativeBinomialDistribution[a,p]][k],k>0]

Simplify[CDF[NegativeBinomialDistribution[k,p]][n-k], n>k]

Simplify[PDF[NegativeBinomialDistribution[n-k,1-p]][k],k>0]

Simplify[CDF[NegativeBinomialDistribution[n-k,1-p]][k],k>0]

Median[NegativeBinomialDistribution[n-k,1-p]]

BetaRegularized[1 - p, -k + n, 1 + Floor[k]]

Plot[BetaRegularized[1 - 1/100, -1000+n, 1000], {n,0,200000}]

Plot[s[1000,n,1/100],{n,0,200000}, PlotRange -> All]



BetaRegularized[1/100, 1000, n-999]

Plot[BetaRegularized[1/100, 1000, n-999], {n,99000,101000}]

Plot[(1 - 1/100)^(-1000 + n)*p^1000*Binomial[-1 + n, -1 + 1000], 
 {n,99000,101000}]

Plot[s[1000,n,1/100],{n,99666,100333}]
