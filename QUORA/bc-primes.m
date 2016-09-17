(*

https://www.quora.com/We-randomly-generate-digits-of-a-decimal-number-until-we-obtain-a-prime-number-Are-we-sure-to-ultimately-get-one

**The probability is "probably" 100%, but it's not that easy to show, and takes a long time to converge**

For convenience, I'm going to refer to generating a random digit (ie, a number from 0 through 9 inclusive) as a "roll" as in "rolling a 10-sided dice" (numbered 0 through 9).

Suppose you've rolled several times and failed to hit a prime along the way. What sort of number do you have? One example is if you roll 9, 1, 3, 5, 1, 9, 0, 2 in that order. You then have:

* 9 is not prime (3*3)
* 91 is not prime (7*13)
* 913 is not prime (11*83)
* 9135 is not prime (3*5*7*29)
* 91351 is not prime (13*7027)
* 913519 is not prime (149*6131)
* 9135190 is not prime (2*5*149*6131)
* 91351902 is not prime (2*3*1399*10883)

Is there a name for numbers like these that aren't prime and where every prefix is also not prime? Not exactly, but they do form https://oeis.org/A202259

It turns out there are 21,007,948 elements of A202259 that have exactly eight digits like the example above. [TODO: footnote or brute force note here]

Since there are 90,000,000 ways to generate an eight digit number (excluding leading zeros), the chance that you will roll eight digits without hitting a prime is 21,007,948/90,000,000 or about 23.34%. Thus, the chance that you WILL roll a prime number at least once in the first eight rolls is 100% minus this number of 76.66%

For reference, the number of ways you can roll n times without hitting a prime for n=1 through n=8 is:

{5, 38, 320, 2819, 25668, 237586, 2224574, 21007948}

To find these numbers, I generated all elements of A202259 with eight or fewer digits. The results are at https://github.com/barrycarter/bcapps/blob/master/QUORA/ in the file "a202259-through-8-digits.txt.bz2". The total number of entries in this file is 23,498,958, the sum of the numbers above.

If we want to go beyond eight digits, we have a problem: computing elements of A202259 is difficult, and I wasn't able to compute all nine digit elements in order to count them. It's possible someone has done this (either the elements themselves or just the count without generating the elements directly), but I wasn't able to find it.

Unless someone finds a general formula for the number of n digit elements of A202259, we must resort to estimation.

Suppose c is an n digit element of A202259. There are 10 ways we can add a digit at the end of c, resulting in 10 numbers with n+1 digits that start with the digits from 'c'. Of these 10 numbers, if the number itself is not prime, it is also an element of A202259: we know the number itself isn't prime, and, once we remove a digit, we have a elements of A202259, so we know all prefixes are also nonprime.

Of the 10 numbers we create above with n+1 , how many are nonprime? If we estimate they are just as likely to be a nonprime as any other n+1 digit number, we can estimate how many of the 10 numbers are prime. Of course, this IS an estimate, so our calculations from here forward are only estimates. Note that we may even get fractional numbers (for example, we might find 3.6536311 of the 10 number we generate are nonprime, which doesn't make sense literally, but is OK for an estimate).

How likely is it than an n digit number is prime? To find this, we can divide the quantity of n digit primes by the quantity of n digit numbers total. The latter is easy: there are 9*10^(n-1) numbers with n digits total (no leading zeros).

For the former, https://oeis.org/A006879 and https://oeis.org/A006879/b006879.txt give these quantities for n=1 through n=25 (we ignore n=0, as we won't use it). From the text file, these numbers are:

{4, 21, 143, 1061, 8363, 68906, 586081, 5096876, 45086079, 404204977, 3663002302, 33489857205, 308457624821, 2858876213963, 26639628671867, 249393770611256, 2344318816620308, 22116397130086627, 209317712988603747, 1986761935284574233, 18906449883457813088, 180340017203297174362, 1723853104917488062633, 16510279375742396898943, 158410709631794568543814}

Dividing by 9*10^n, the probability of an n digit number being prime (for n=1 to n=25) is (rounded to four digits):

{0.4444, 0.2333, 0.1589, 0.1179, 0.0929, 0.0766, 0.0651, 0.0566, 0.0501, 0.0449, 0.0407, 0.0372, 0.0343, 0.0318, 0.0296, 0.0277, 0.026, 0.0246, 0.0233, 0.0221, 0.021, 0.02, 0.0192, 0.0183, 0.0176}

Of course, we're interested in the probability than an n digit number is NOT prime, so we just subtract from 1 to get:

{0.5556, 0.7667, 0.8411, 0.8821, 0.9071, 0.9234, 0.9349, 0.9434, 0.9499, 0.9551, 0.9593, 0.9628, 0.9657, 0.9682, 0.9704, 0.9723, 0.974, 0.9754, 0.9767, 0.9779, 0.979, 0.98, 0.9808, 0.9817, 0.9824}

How can we use these probabilities to count (estimate) how many elements of A202259 have more than eight digits?

We know that there are 21,007,948 eight digit elements of A202259. If we add a digit to each of these, we have 210,079,480 numbers total. From the above, we know that approximately 0.9499 of these will be non-prime. Thus, we can estimate that, to the nearest whole number, there are  199,555,413 nine digit elements of A202259 (this is 0.9499*210079480, but, to preserve accuracy, I used exact numbers and THEN rounded to the nearest whole number).

Using a similar technique, we can estimate the number of n digit elements of A202259 all the way to n=25 (for n=1 to n=8, we use the exact values above):

{5, 38, 320, 2819, 25668, 237586, 2224574, 21007948, 199555413, 1905930476, 18283590569, 176032407499, 1699992365761, 16459916131126, 159727094047892, 1553009893530716, 15125571122440316, 147538787471478048, 1441074006302956646, 14092621065068371251, 137965750274091745514, 1352012229654366891541, 13261158909879658216032, 130178862004927374960014, 1278875591261207077472524}

And, from these estimates, we can estimate the chance of rolling n digits without ever hitting a prime, as we did previously for 8 digits (rounded to 4 digits):

TODO: these numbers can't be right

{0.5556, 0.4222, 0.3556, 0.3132, 0.2852, 0.264, 0.2472, 0.2334, 0.2217, 0.2118, 0.2032, 0.1956, 0.1889, 0.1829, 0.1775, 0.1726, 0.1681, 0.1639, 0.1601, 0.1566, 0.1533, 0.1502, 0.1473, 0.1446, 0.1421}

Note that, after 25 rolls, the chance that you STILL haven't hit a prime number is about 14.21% (roughly 1 in 7).

What about after 26 rolls? We can't use the method above, since the number of 26 digit primes is unknown (or, at the very least, I haven't found it).

Instead, let's try to approximate the probability that an n digit number will be prime for n>=26.

I don't know of any mathematical notation for the number of n digit primes, but there is one for primes less than n, namely [math]\pi (n)[/math] (https://en.wikipedia.org/wiki/Prime-counting_function). Of course, this is different from the more common usage of [math]\pi[/math] as the ratio of a circle's circumference to its diameter.

Using this, we see that [math]\pi \left(10^{n+1}\right)[/math] is the number of primes with n or fewer digits. By subtracting off [math]\pi \left(10^n\right)[/math], the number of primes with n-1 or fewer digits, we get 

TODO: wrong below

[math]\pi \left(10^n\right)-\pi \left(10^{n-1}\right)[/math] as the number of primes with precisely n digits. Since there are [math]9\ 10^{n-1}[/math] n digit numbers total, the probability than an n digit number is prime is (after simplification):

[math]p(n) = \frac{1}{9} 10^{1-n} \left(\pi \left(10^{n+1}\right)-\pi \left(10^n\right)\right)[/math]

Let a(n) be the n digit elements of A202259. By the discussion earlier, we have:

[math]a(n+1) = 10 a(n) (1-p(n+1))[/math]

Substituting for p(n) and simplifying, we have:

[math]a(n+1) = \frac{10}{9} a(n) \left(10^{1-n} \left(\pi \left(10^n\right)-\pi \left(10^{n+1}\right)\right)+9\right)[/math]

with our initial condition a(8) = 21007948, since we want to use exact values as far as possible.

(* below is a generalization of the process 

(* number of primes less than or equal to n *)
c0[n_] = PrimePi[n]

(* chance an n digit number is prime *)
c1[n_] = (c0[10^n]-c0[10^(n-1)])/9/10^(n-1)

(* chance that a n digit number is a member of A202259, recursive *)

c2[n+1] == (c2[n]*9*10^(n-1))*10*(1-c1[n+1])/9/10^n

TODO: improve this by not subtracting out lower primes?





(* n digit members of A202259, as equivalence *)

c2[n+1] == c2[n]*10*(1-c1[n+1])









p[n_] = (PrimePi[10^n]-PrimePi[10^(n-1)])/9/10^(n-1)

RSolve[{
 a[8] == 21007948,
 a[n+1] ==  10*a[n]*(1-p[n+1])
}, a[n], n]

{{a[n] -> (322052448838500000000000000000000*
     Product[(10^(1 - K[1])*(9*10^K[1] + PrimePi[10^(1 + K[1])] - 
         PrimePi[10^(2 + K[1])]))/9, {K[1], 1, -1 + n}])/
    20223505963127102965144579127}}

b[n_] = FullSimplify[a[n] /. %[[1,1]], {Element[n,Integers], n>2}]

mathematica wont eval limit

q[n_] = FullSimplify[(LogIntegral[10^n]-LogIntegral[10^(n-1)])/9/10^(n-1),
 {Element[n,Integers], n>2}]

RSolve[{
 a[8] == 21007948,
 a[n+1] ==  10*a[n]*(1-q[n+1])
}, a[n], n]

b[n_] = FullSimplify[a[n] /. %[[1,1]], {Element[n,Integers], n>2}]

c[n_] = b[n]/10^(n-1)/9

Table[N[c[n]],{n,1,500}]

RSolve[{
 la[8] == Log[21007948],
 la[n+1] ==  Log[10]+Log[la[n]]+Log[(1-q[n+1])]
}, la[n], n]

FullSimplify[LogIntegral[E^2]]

ExpIntegralEi

LogLogPlot[b[n]/9/10^(n-1), {n,1,500}]


RSolve[{
 a[25] == 158410709631794568543814,
 a[n+1] ==  10*a[n]*(1-q[n+1])
}, a[n], n]

(* above runs out of memory! *)

RSolve[a[n+1] ==  10*a[n]*(1-q[n+1]), a[n], n]

{{a[n] -> C[1]*Product[(10^(1 - K[1])*(9*10^K[1] + LogIntegral[10^(1 +
K[1])] - LogIntegral[10^(2 + K[1])]))/9, {K[1], 1, -1 + n}]}}

b1[n_] = FullSimplify[a[n] /. %[[1,1]], {Element[n,Integers], n>2}]

Solve[b1[25] == 158410709631794568543814, C[1]]

(* above ALSO runs out of memory *)

Solve[b1[8] == 21007948, C[1]]

b2[n_] = b1[n] /. C[1] -> %[[1,1,2]]

q[n_] = FullSimplify[(LogIntegral[10^n]-LogIntegral[10^(n-1)])/9/10^(n-1),
 {Element[n,Integers], n>2}]

RSolve[{
 a[1] == 5,
 a[n+1] ==  10*a[n]*(1-q[n+1])
}, a[n], n]

b[n_] = FullSimplify[a[n] /. %[[1,1]], {Element[n,Integers], n>2}]





TODO: 10^48th prime problem mention

NOTE TO SELF: RSolve[{a[0]=1; a[n+1] == a[n]+1}, a[n], n] does work
(don't need a[n] on left side) (TODO: remove this before posting)


10*a[n]*(1-p[n])




Limit[PrimePi[n]/n, n -> Infinity] fail (but can eval at non ints)

Limit[LogIntegral[n]/n, n -> Infinity] works






By adding a digit to an n-1 digit element of A202259, we create an n digit number 

TODO: check all math formulas before uploading


{0.556, 0.422, 0.356, 0.313, 0.285, 0.264, 0.247, 0.233, 0.222, 0.212, 0.203, 0.196, 0.189, 0.183, 0.177, 0.173, 0.168, 0.164, 0.16, 0.157, 0.153, 0.15, 0.147, 0.145, 0.142}






(* number of n digit primes *)

oeis6879 = {4, 21, 143, 1061, 8363, 68906, 586081, 5096876,
45086079, 404204977, 3663002302, 33489857205, 308457624821,
2858876213963, 26639628671867, 249393770611256, 2344318816620308,
22116397130086627, 209317712988603747, 1986761935284574233,
18906449883457813088, 180340017203297174362, 1723853104917488062633,
16510279375742396898943, 158410709631794568543814};

acts = {5, 38, 320, 2819, 25668, 237586, 2224574, 21007948}

a[n_] := If[n<=8, acts[[n]], a[n-1]*10*(1-oeis6879[[n]]/9/10^(n-1))]

210079480*(1-oeis6879[[9]]/10^8/9)

Table[a[n],{n,1,25}]
In[25]:= Table[Round[a[n],1],{n,1,25}]                                          

(.9499*210079480 but I used exactly values


TODO: use element consistently, not member; say whole number, not integer

===== CUT POINT ====

TODO: graph????

N[Round[Table[oeis6879[[i]]/9/10^(i-1),{i,1,25}],10^-4]]




For example, with three random digits, you can generate a total of 900 numbers (no leading zeros), of which 320 (the third number above) will never hit a prime. Thus, your chance of failure after 3 digits is 320/900, and your chance of success is thus 1-320/900 or 580/900 which reduces to 29/45 or about 64.44%

With eight digits, the chance of failure is 21007948/90000000, yielding a chance of success of about 76.66%

I computed all 23,498,958 members of A202259 with eight or fewer digits at https://github.com/barrycarter/bcapps/blob/master/QUORA/ in "a202259-through-8-digits.txt.bz2", but couldn't go beyond eight digits because of computational/memory limits.

Thus, for n>=9, we must use a recursive estimation. Allowing c[n] to be the number of A202259 elements with exactly n digits, we have:

TODO: put stuff here

b[n_] := If[n<=25,oeis6879[[n+1]], LogIntegral[10^n]-LogIntegral[10^(n-1)]];

c[n_] := 10*c[n-1]*(1-b[n]/9/10^(n-1))

c[1] := 5

ListPlot[Table[c[i],{i,1,25}]]

N[Log[Table[c[i],{i,1,25}]]]

TODO: go as far as possible for c[n] with actual values

p[n_] = FullSimplify[(10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/9/10^(n-1),
 {Element[n,Integers], n>2}]


RSolve[{
 c[1] == 5,
 c[n] == 10*c[n-1]*(1-p[n])
 }, c[n], n]

above gives proof of 0

p[n_] = FullSimplify[(LogIntegral[10^n] - LogIntegral[10^(n-1)])/9/10^(n-1),
 {Element[n,Integers], n>2}]

RSolve[{
 c[1] == 5,
 c[n] == 10*c[n-1]*(1-p[n])
 }, c[n], n]

p[n_] = FullSimplify[(PrimePi[10^n] - PrimePi[10^(n-1)])/9/10^(n-1),
 {Element[n,Integers], n>2}]

RSolve[{
 c[1] == 5,
 c[n] == 10*c[n-1]*(1-p[n])
 }, c[n], n]




RSolve[{
 c[1] == 5,
 c[n] == 10*c[n-1]*(1-(LogIntegral[10^n]-LogIntegral[10^(n-1)])/9/10^(n-1))
 }, c[n], n]


RSolve[{
 c[1] == 5,
 c[n] == 10*c[n-1]*(1-(PrimePi[10^n]-PrimePi[10^(n-1)])/9/10^(n-1))
 }, c[n], n]


RSolve[{
 c[1] == 5,
 c[n] == 10*c[n-1]*(1-(10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/9/10^(n-1))
 }, c[n], n]





TODO: legacy note

TODO: note on OEIS that removing digit from A069090 yields A202259

I found this problem interesting and did some work on it at https://github.com/barrycarter/bcapps/blob/master/QUORA/bc-primes.m and am summarizing the more important results below.

If and when you end on a prime number, it must be a member of https://oeis.org/A069090 "Primes none of whose proper initial segments are primes".

For example, you can stop at 91351901 since 91351901 is prime, but as you remove digits right to left:

* 9135190 is not prime (2*5*149*6131)
* 913519 is not prime (149*6131)
* 91351 is not prime (13*7027)
* 9135 is not prime (3*5*7*29)
* 913 is not prime (11*83)
* 91 is not prime (7*13)
* 9 is not prime (3*3)

However, you can NOT stop at 91535303, because, even though 91535303 itself is prime, here's what happens when you start removing digits right to left:

* 9153530 is not prime (2*5*915353)
* 915353 IS prime

That means you would've stopped at 915353 without generating any additional random digits.

I constructed the 1,411,151 members of A069090 that are eight digits or fewer with the compressed results at https://github.com/barrycarter/bcapps/blob/master/QUORA/A069090-thru-8-digits.txt.bz2

Minor caveats for the discussion below:

* Generating one or more zeros at the start of your number does not change the probability since you will eventually (with probability 1) generate a non-zero digit, at which point your probability count starts.

* Consistent with A069090, I regard 1 as non-prime. Regarding 1 as prime may or may not drastically change the results below, and it would be an interesting extension of this problem to see if that is the case.

* To emphasize that 1 is neither prime nor composite, I refer to numbers below as non-prime and not "composite".

Suppose we generate eight random digits in a row, ignoring for the moment whether we hit any primes on the way or not. This means we are equally likely to generate any of the 9*10^7 numbers from 10000000 to 99999999. Now, let's see how many of these 9*10^7 numbers yield prime numbers:

* If the generated number is one of the 4*10^7 numbers that start with {2,3,5,7}, we have found a prime number on the first digit, regardless of what the remaining 7 digits are.

* There are 12 two digit members of A069090 (two digit primes where the first digit isn't prime). If the number we generate is one of 12*10^6 numbers that starts with a two digit member of A069090, we have found a prime number on the second digit, regardless of what the remaining 6 digits are. Note that we are not double counting the primes found in the first step because we only count primes where the first digit isn't prime.

* There are 60 three digit members of A069090 (three digit primes where neither the first digit nor the first two digits are prime). If we generate any number starting with these three digits, the remaining 5 digits can be anything, giving us additional 60*10^5 where we find a prime, again not doublecounting the ones we already found.

* Similarly there are 381 four digit members of A069090 giving us another 381*10^4 eight digit numbers, 2522 five digit members for another 2522*10^3, 19094 six digit members for another 19094*10^2, 151286 seven digit members for another 151286*10, and 1237792 eight digit members for a final 1237792 more.

* Adding these up, we see that, of the 9*10^7 ways to generate eight digits, we will hit a prime number 68992052 times, or about 68992052/(9*10^7) (~76.66%) of the time.

In other words, if we stopped after generating eight digits, our chance of hitting a prime somewhere along the way would be about 76.66%.

What happens if we continue to nine digits or more? Unfortunately, I couldn't get Mathematica to generate the nine digit members of A069090, so we must resort to estimation.

TODO: add to OEIS too: non-prime + removing digits still non-prime, and the number there in and generate up to 8 or 9 digits


https://oeis.org/A202259

To do this, let's consider numbers with the following two properties:

* The number is not prime
* When we remove digits from right to left, the number remains non-prime.

Let's refer to this (infinite) set as S.

As an example, the two digit members of S.

{10, 12, 14, 15, 16, 18, 40, 42, 44, 45, 46, 48, 49, 60, 62, 63, 64, 65, 66, 68, 69, 80, 81, 82, 84, 85, 86, 87, 88, 90, 91, 92, 93, 94, 95, 96, 98, 99}

Note that none of these numbers are prime, and all start with {1,4,5,6,8,9}, so removing a digit from the right leaves them non-prime


TODO: relation to A069090 by digit exclusion, use later to compute



Let c(n) be the quantity of n digit numbers in S. We can now estimate (not compute exactly!) c(n) recursively as follows:

STEP 1: 





1,4,6,8,9


Consider the following recursive procedure for estimating the number of n-digit members of A069090:

* STEP 1: Suppose we know how many members of A069090 have n digits and call this a(n)

* STEP 2: To create an n+1 digit member of A069090, our new number can't start with any of these a(n) numbers.


* STEP 3: There are 9*10^(n-1) n digit numbers total, and thus 9*10^(n-1)-a(n) n digit numbers that are NOT members of A069090

* STEP 4: We can add any digit to these 9*10^(n-1)-a(n) numbers to form candidates for n+1 digit members of A069090. Thus, there are 10*(9*10^(n-1)-a(n)) candidates for n+1 digit members of A069090

* STEP 5a: We now take the estimation step by computing the probability that an n+1 digit is prime and assuming that the candidates generated in STEP 4 are as likely to be primes as any other n+1 digit number. Note that this assumption is false, which is why this process yields only an estimate and not an not an exact number.

* STEP 5b: The probability than a randomly selected n+1 digit number is prime is the number of primes of length n+1 divided by the total number of n+1 digit numbers. The latter is 9*10^n. The former is the n+1st member of https://oeis.org/A006879. If we refer to the former as b(n+1), the probability that a randomly selected n+1 digit number is prime is b(n+1)/(9*10^n)

* STEP 5c: Combining STEP 5a and STEP 5b, we estimate a(n+1) as:

a(n+1) = b(n+1)/(9*10^n)*(10*(9*10^(n-1)-a(n)))

which simplifies to:

[math]a(n+1)=\frac{1}{9} \left(9-10^{1-n} a(n)\right) b(n+1)[/math]

Since we know there are 4 one digit members of A069090 (namely, {2,3,5,7}), our initial condition is a(1)=4

TODO: section marker here?

We can now use https://oeis.org/A006879/b006879.txt and the recursion above to estimate how many n digit members of A069090 there are.

The estimates for the first 8 digits (rounded to the nearest whole number) are:

WRONG!!!! {4, 12, 124, 914, 7513, 63154, 544955, 4788257}



The actual values I computed are:

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}


Table[Round[a[n],1],{n,1,8}]





FullSimplify[(b[n + 1]*(10*(9*10^(n - 1) - a[n])))/(9*10^n), 
    {Element[n, Integers], n > 2}]

reduce n by 1 to get

a[n_] := ((9 - 10^(2 - n)*a[-1 + n])*b[n])/9
a[1] := 4;

TODO: note I'm trying to get OEIS for n digit ones







TODO: consider texifying inline equations






TODO: restore below if above fails

TODO: mention prior versions

* STEP 0: There are 5 one digit non-prime numbers {1,4,6,8,9}

* STEP 1: From these we can generate 5*10 two digit numbers that start with a non-prime digit: 10 each for 1, 4, 6, 8, and 9. For example, for the non-prime number 4, we generate the two digit numbers {40, 41, 42, ..., 49}.

* STEP 2: We determine or estimate what percentage of two digit numbers are prime. There are 21 two-digit primes, so there is 21/90 chance that a given two digit number is prime. In general, https://oeis.org/A006879 gives us the number of n-digit primes, and there 9*10^(n-1) n-digit numbers, so the odds of an n-digit number being prime is the ratio of these two numbers.

* STEP 3: We now assume that the numbers generated in STEP 1 are as likely to be prime as any two digit numbers. In other words, they each have a 21/90 chance of being prime. This isn't actually true, and is one reason this estimation isn't exact. In this case, it tells us 21/90*50 = 35/3 of the numbers generated in STEP 1 are prime. This is obviously incorrect (a whole number can't be a fraction), but is close to the true value of 12.

* STEP 4: If 35/3 of the numbers are prime, 50-35/3 or 115/3 (about 38) are not prime.

* STEP 5: We can use these 38 not prime numbers to generate 380 three digit numbers where neither the first digit nor the first two digits are prime.

* STEP 6: We can then repeat STEPS 2 through 4 to find how many three-digit members AA069090 has, and repeat the process for four-digit members, five-digit members, etc.

Computing the value in STEP 2 is actually a bit tricky for more than a handful of digits. The exact value is [math]\pi \left(10^n\right)-\pi \left(10^{n-1}\right)[/math], where [math]\pi[/math] is the prime counting function. Using this, we can compute the number of n-digit members of AA069090 for n=1 to n=14 as:

[math]\{4, 12, 61, 380, 2643, 19752, 155139, 1261313, 10525491, 89635783, 775819148, 6804418731, 60339872334, 540080591492\}[/math]

This agrees fairly closely with the known values for n=1 to n=8:

[math]\{4,12,60,381,2522,19094,151286,1237792\}[/math]

and extends the table to n=14.

Unfortunately, computing [math]\pi(10^n)[/math] for large values becomes difficult. You can get a little further using the log integral function [math]\text{li}\left(10^n\right)-\text{li}\left(10^{n-1}\right)[/math], which is approximately equal to the prime counting function, but slightly easier to compute.

However, even the log integral function isn't that easy to compute for large values of n, so we fall back on an even less-accurate but easier to compute approximation: https://en.wikipedia.org/wiki/Prime_number_theorem 


TODO: disclaim, check my work





TODO: mention all Cali's are base 10

TODO: use non-prime not composite


There are 4 one-digit members of A069090 (namely {2,3,5,7}), so there is a 4/9 (44.44...%) chance you will generate a prime on your first digit. 

* There is a 5/9 chance you won't generate a prime as your first digit, in which case there are 50 possible numbers (10 for each of {1,4,6,8,9}) after you've generated your second digit. Of these, 12 are prime, so there's a 12/50 (24%) chance your second number will be prime, 

TODO: make sure I don't use "roll" as in "dice roll" anywhere


Plot[LogIntegral[10^n]/10^n,{n,0,100}]

Plot[LogIntegral[10^n]/Log[10^n],{n,0,100}]

Plot[LogIntegral[10^n]/10^n,{n,100,200}]

Plot[10^n/LogIntegral[10^n],{n,1,200}]

Plot[10^n/LogIntegral[10^n]/n,{n,1,200}]

Plot[10^n/LogIntegral[10^n]/n,{n,100,200}]

Limit[10^n/LogIntegral[10^n]/n, n -> Infinity]
Log[10]

Limit[Exp[n]/LogIntegral[Exp[n]]/n, n -> Infinity]

(above is 1, but we need 10 version)

PrimePi[10]/10

(1-PrimePi[10]/10)*PrimePi[10^2]/10^2

(* cant choose 0 as first digit *)

a[1] = 4/9;

(* below should be 1-a[n-1] but not fixing, not using *)

a[n_] := a[n-1]*PrimePi[10^n]/10^n

appears to be eulergamma number

but above is wrong, because all prev numbers must be nonprime

Clear[a]

a[1] = 4/9;

a[n_] := (1-Sum[a[i],{i,1,n-1}])*PrimePi[10^n]/10^n

Sum[a[i],{i,1,10}]

bigger than one, something wrong, fixed

Clear[a]

a[1] = 4/9;

a[n_] := (1-Sum[a[i],{i,1,n-1}])*LogIntegral[10^n]/10^n

Sum[a[i],{i,1,10}]

prime1 = {2,3,5,7}

comp1 = Complement[Range[1,9], prime1]

digitify[l_] := Flatten[Table[Range[i*10,i*10+9],{i,l}]]

prs = Select[digitify[comp1], Not[PrimeQ[#]]&]

TODO: note leading 0s irrelev, assuming 1 is nonprime

(* START: the following lines compute actual values *)

digitify[l_] := Flatten[Table[Range[i*10,i*10+9],{i,l}]]

tab[1] = Range[1,9];
primes[1] = Select[tab[1], PrimeQ];
comps[1] = Complement[tab[1], primes[1]];

tab[n_] := tab[n] = digitify[comps[n-1]];
primes[n_] := primes[n] = Select[tab[n], PrimeQ];
comps[n_] := comps[n] = Complement[tab[n], primes[n]];

(* length below is TODO 23,498,958 *)

test = Flatten[Table[comps[i],{i,1,8}]];

Table[Length[comps[i]],{i,1,8}]

{5, 38, 320, 2819, 25668, 237586, 2224574, 21007948}



(* length below is 1,411,151 *)

Export["/tmp/A069090-thru-8-digits.txt",Flatten[Table[primes[i],{i,1,8}]]];

(* values of length of primes(n) *)

lens = {4, 12, 60, 381, 2522, 19094, 151286, 1237792};

(* probability computation using first 8 elts, 10/9 to avoid leading 0s *)

Sum[lens[[i]]/10^i,{i,1,8}]*10/9

17248013/22500000 ~ .7666

(* confirms that primes[8] is correct *)

Length[Select[primes[8], PrimeQ]]

test1 = DeleteDuplicates[Floor[primes[8]/10]];

Select[test1, PrimeQ]

test2 = DeleteDuplicates[Floor[test1/10]];

(and so on, didnt actually finish)

(* END *)

Your search - A069090 10000019 - did not match any documents. 

https://oeis.org/A069090 is the sequence above

http://math.stackexchange.com/questions/437759/number-of-digits-until-a-prime-is-reached

(* START: estimation of primecount using PrimePi *)

tabcount[1] = 9
primecount[1] = 4
compcount[1] = 5

tabcount[n_] := tabcount[n] = 10*compcount[n-1]

primecount[n_] := primecount[n] = 
 (PrimePi[10^n]-PrimePi[10^(n-1)])/9/10^(n-1)*tabcount[n]

compcount[n_] := compcount[n] = tabcount[n] - primecount[n]

Table[Length[primes[i]],{i,1,8}]

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}

Round[Table[primecount[i],{i,1,8}],1]

{4, 12, 61, 380, 2643, 19752, 155139, 1261313}

Round[Table[primecount[i],{i,9,14}],1]

{10525491, 89635783, 775819148, 6804418731, 60339872334, 540080591492}

(* estimation of probability using first 14 terms *)

Sum[primecount[i]/10^i,{i,1,14}]*10/9

5769239667962329296128102642713634610997301906201732145202659062306852290804976687308629060016397527 / 7060738412025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

about 0.8171

(* END *)

(* START: estimation of primecount using LogIntegral *)

litabcount[1] = 9
liprimecount[1] = 4
licompcount[1] = 5

litabcount[n_] := litabcount[n] = 10*licompcount[n-1]

liprimecount[n_] := liprimecount[n] = 
 (LogIntegral[10^n]-LogIntegral[10^(n-1)])/9/10^(n-1)*litabcount[n]

licompcount[n_] := licompcount[n] = litabcount[n] - liprimecount[n]

Table[Length[primes[i]],{i,1,8}]

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}

Round[Table[liprimecount[i],{i,1,8}],1]

{4, 13, 60, 364, 2518, 18795, 147462, 1198538}

Round[Table[liprimecount[i],{i,9,18}],1]

{10000994, 85167545, 737144504, 6465207476, 57331798029, 513156310634,
4629809442726, 42060217553835, 384413132350436, 3532103986572052}

(* estimation of probability using first 18 terms *)

Sum[N[liprimecount[i]]/10^i,{i,1,18}]*10/9

approx 0.844219

ListLogPlot[Table[liprimecount[i],{i,1,18}]]

ListPlot[Table[liprimecount[i]/10^i,{i,1,18}]]

(* END *)

(* START: estimation of primecount using Prime number theorem *)

pnttabcount[1] = 9
pntprimecount[1] = 4
pntcompcount[1] = 5

pnttabcount[n_] := pnttabcount[n] = 10*pntcompcount[n-1]

pntprimecount[n_] := pntprimecount[n] = 
 (10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/9/10^(n-1)*pnttabcount[n]

pntcompcount[n_] := pntcompcount[n] = pnttabcount[n] - pntprimecount[n]

Table[Length[primes[i]],{i,1,8}]

{4, 12, 60, 381, 2522, 19094, 151286, 1237792}

Round[Table[pntprimecount[i],{i,1,8}],1]

{4, 10, 55, 364, 2634, 20211, 161584, 1331341}

Round[Table[pntprimecount[i],{i,9,17}],1]

{11224488, 96363928, 839507738, 7402589144, 65939592589, 592456087663,
5362822842970, 48858408149798, 447663271799097}

(* estimation of probability using first 17 terms *)

Sum[N[pntprimecount[i]]/10^i,{i,1,17}]*10/9

approx 0.8089

FullSimplify[(10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/9/10^(n-1), {Element[n
,Integers], n>2}]

(* END *)

TODO: use below

10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)]





f[n_] = FullSimplify[(10^n/Log[10^n] - 10^(n-1)/Log[10^(n-1)])/9/10^(n-1), 
 {Element[n  ,Integers], n>2}]



moretabcount[1] = 9
moreprimecount[1] = 4
morecompcount[1] = 5

moretabcount[n_] := moretabcount[n] = 10*morecompcount[n-1]

moreprimecount[n_] := moreprimecount[n] = f[n]*moretabcount[n]

morecompcount[n_] := morecompcount[n] = moretabcount[n] - moreprimecount[n]

mtc[n] = 10*mcc[n-1] = 10*(mtc[n-1] - mpc[n-1]) =
 10*(mtc[n-1] - (f[n-1]*mtc[n-1])) = 10*mtc[n-1]*(1-f[n-1])

RSolve[{mtc[1] == 9, mtc[2] == 50, 
 mtc[n] == 10*(1-f[n-1])*mtc[n-1]}, mtc[n], n]

(* below works!!! *)

mtcc[n_] = mtc[n] /.
RSolve[{mtc[2] == 50, 
 mtc[n] == 10*(1-f[n-1])*mtc[n-1]}, mtc[n], n][[1]]

(* the above actually does mtc well *)

mpcc[n_] = mtcc[n]*f[n]

Sum[mpcc[n]/10^n,{n,9,Infinity}]*10/9

about 0.262094 + 0.6899 = 0.951994

about 0.255484 + 0.6899 = 0.945405

N[Sum[mpcc[n]/10^n,{n,15,Infinity}]] + 0.714722388 about 0.921815

Sum[mpcc[n]/10^n,{n,19,Infinity}]

about 0.188203 + 0.739406 = 0.927609



FullSimplify[mpcc[n], {Element[n,Integers],n>2}]

mpc2[n_] = 
(2^(-2 + n)*5^(-1 + n)*(-10 + 9*n)*
  Pochhammer[(-9 + 30*Log[10] + Sqrt[81 + 20*Log[10]*(-11 + 5*Log[10])])/
    (20*Log[10]), -2 + n]*Pochhammer[
   3/2 - (9 + Sqrt[81 + 20*Log[10]*(-11 + 5*Log[10])])/(20*Log[10]), -2 + n])/
 (n!*Gamma[n]*Log[10])









(* below is just test *)

mtc[1] = 9
mtc[2] = 50
mtc[n_] := 10*(1-f[n-1])*mtc[n-1]
Clear[mtc]






TODO: use N versions of these, might be much faster

TODO: you can get full list at...

sum = Sum[Length[primes[n]]/10^n,{n,1,8}]

17248013/25000000

0.689921, li approx is 0.679404

close to natural log of 2

est length for longer than 8 digits

tab[n] will be 10*comps[n-1]

primes[n] will be (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n times that

comps[n] will be 10*comps[n-1] - above

tabcount[1] = 9
primecount[1] = 4
compcount[1] = 5

tabcount[n_] := tabcount[n] = 10*compcount[n-1]

primecount[n_] := primecount[n] = 
 (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabcount[n]

compcount[n_] := compcount[n] = tabcount[n] - primecount[n]


RSolve[{
 tabcount[n] == 10*compcount[n-1],
 primecount[n] == (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabcount[n],
 compcount[n] == tabcount[n] - primecount[n],
 tabcount[1] == 9,
 primecount[1] == 4,
 compcount[1] == 5
}, primecount, n]

RSolve[{
 tabcount[n] == 10*(tabcount[n-1] - primecount[n-1]),
 primecount[n] == (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabcount[n],
 tabcount[1] == 9,
 primecount[1] == 4
}, primecount[n], n]

RSolve[{
tabcount[n] == 10*(tabcount[n-1] - (
 LogIntegral[10^(n-1)]-LogIntegral[10^(n-2)])/10^(n-1)*tabcount[n-1]
), tabcount[1] == 9, tabcount[2] == 21}, tabcount[n], n]

tabtest[1] = 9;
tabtest[2] = 50;
tabtest[n_] := tabtest[n] = 10*(tabtest[n-1] - (
 LogIntegral[10^(n-1)]-LogIntegral[10^(n-2)])/10^(n-1)*tabtest[n-1]);

primetest[n_] := 
 (LogIntegral[10^n]-LogIntegral[10^(n-1)])/10^n*tabtest[n]

TODO: sequence of primes meeting condition is itself interesting

(* above is confirmed accurate with tabcount earlier *)


RSolve[{
tabcount[n] == 10*(tabcount[n-1] - (
 LogIntegral[10^(n-1)]-LogIntegral[10^(n-2)])/10^(n-1)*tabcount[n-1]
), tabcount[1] == 9, tabcount[2] == 50}, tabcount[n], n]






0.745892 with first 20

above is remarkably good!


TODO: if posting as stack, note awareness of other question



"4,21,139,1032" = num primes exactly n digits

Table[PrimePi[10^n]-Sum[PrimePi[10^i],{i,1,n-1}],{n,1,8}]

WRONG: {4, 21, 139, 1032, 8166, 67480, 575063, 5007360}

Table[PrimePi[10^n]-PrimePi[10^(n-1)],{n,1,8}]

https://oeis.org/A006879 is that

primes will be 

TODO: different bases (trivial for 2), what if 1 is prime, OEIS

primes[8][[Floor[Length[primes[8]]*Random[]]]]

91351901 (where 1 is considered composite)

tab[8] is highest w/o out of memory

















(*

**Assuming the Riemann Hypothesis, the [math]10^{48}[/math]th prime is between 114,253,594,378,425,466,185,102,853,920,130,817,319,525,886,680,889 and 114,253,594,378,425,466,185,114,154,511,712,329,201,522,001,657,619, and most likely towards the middle of this range.**

If we assume the Riemann Hypothesis and https://en.wikipedia.org/wiki/Prime_number_theorem#Prime-counting_function_in_terms_of_the_logarithmic_integral we have:

[math]\left| \pi (x)-\text{li}(x) \right|<\frac{\sqrt{x} \log (x)}{8 \pi }[/math]
or
[math]\text{li}(x)-\frac{\sqrt{x} \log (x)}{8 \pi }<\pi(x)<\text{li}(x)+\frac{\sqrt{x} \log (x)}{8 \pi }[/math]
given that [math]x\geq 2567[/math] and thus [math]\pi (x)\geq 375[/math].

Using Mathematica, we find 114253594378425466185102853920130817319525886680866 (114,253,594,378,425,466,185,102,853,920,130,817,319,525,886,680,866) is the largest integer n satisfying [math]\text{li}(n)+\frac{\sqrt{n} \log (n)}{8 \pi }<10^{48}[/math] and thus necessarily [math]\pi (n)<10^{48}[/math].

That means our smallest candidate for the [math]10^{48}[/math]th prime is the next prime after that number, which turns out to be 114253594378425466185102853920130817319525886680889 (114,253,594,378,425,466,185,102,853,920,130,817,319,525,886,680,889).

Similarly, 114253594378425466185114154511712329201522001657687 (114,253,594,378,425,466,185,114,154,511,712,329,201,522,001,657,687) is the smallest integer n satisfying [math]\text{li}(n)-\frac{\sqrt{n} \log (n)}{8 \pi }>10^{48}[/math] and thus necessarily [math]\pi (n)>10^{48}[/math].

So our largest candidate for the [math]10^{48}[/math]th prime is the prime number prior to this number, which turns out to be 114253594378425466185114154511712329201522001657619 (114,253,594,378,425,466,185,114,154,511,712,329,201,522,001,657,619).

The integer closest to solving [math]\text{li}(n) = 10^{48}[/math] is 114253594378425466185108504215921573260523944025925 (114,253,594,378,425,466,185,108,504,215,921,573,260,523,944,025,925), but this turns out to be a surprisingly poor estimate of the [math]10^{48}[/math]th prime, per the wikipedia page earlier and per https://en.wikipedia.org/wiki/Skewes%27_number

Just for fun, I ran this process on other powers of 10, but excluding powers less than 3 since, as above, we need [math]\pi (x)\geq 375[/math] for these bounds to work.

Below are the results from [math]10^{3}[/math] to [math]10^{24}[/math] as compared to the actual values from https://oeis.org/A006988 as extended by https://oeis.org/A006988/b006988.txt

[[image18.gif]]

The 'whence' column shows where in the lower bound/upper bound interval the actual value occurs. Note that this number sort of appears to approach 0.5 with crossing it, but Skewes (ibid) shows that the 'whence' can be lower than 0.5, albeit probably not for [math]n \leq 200[/math]

For [math]10^{25}[/math] to [math]10^{100}[/math], we don't have actual values, so can only show the bounds:

[[image19.gif]]

All of the values (without commas, and going to [math]10^{200}[/math]) are also available at https://github.com/barrycarter/bcapps/blob/master/QUORA/ under bc-nth-prime.csv; the Mathematica code is in the same directory under bc-primes.m

*)

TODO: preview channel this

(* determine prime bounds using Schoenfield/Riemann *)

range[x_] = Log[x]*Sqrt[x]/8/Pi

bounds[x_] := bounds[x] = Module[{lb,ub},
 lb = NextPrime[t /. FindRoot[LogIntegral[t]+range[t] == x, {t,x*Log[x]},
  WorkingPrecision -> Log[x], AccuracyGoal -> Log[x],
  PrecisionGoal -> Log[x]],1];
 ub = NextPrime[t /. FindRoot[LogIntegral[t]-range[t] == x, {t,x*Log[x]},
  WorkingPrecision -> Log[x], AccuracyGoal -> Log[x],
  PrecisionGoal -> Log[x]],-1];
 Return[{lb,ub}]
];

tab1039 = Table[{x,bounds[10^x]},{x,3,200}]

actval[3] = 7919
actval[4] = 104729
actval[5] = 1299709
actval[6] = 15485863
actval[7] = 179424673
actval[8] = 2038074743
actval[9] = 22801763489
actval[10] = 252097800623
actval[11] = 2760727302517
actval[12] = 29996224275833
actval[13] = 323780508946331
actval[14] = 3475385758524527
actval[15] = 37124508045065437
actval[16] = 394906913903735329
actval[17] = 4185296581467695669
actval[18] = 44211790234832169331
actval[19] = 465675465116607065549
actval[20] = 4892055594575155744537
actval[21] = 51271091498016403471853
actval[22] = 536193870744162118627429
actval[23] = 5596564467986980643073683
actval[24] = 58310039994836584070534263

Table[actval[i]="", {i,25,200}]

tab1901 = Table[{i, bounds[10^i][[1]], bounds[10^i][[2]], actval[i]},
 {i,3,200}];

tab1803 = Table[{HoldForm[10]^i, 
 NumberForm[bounds[10^i][[1]], DigitBlock -> 3],
 NumberForm[bounds[10^i][[2]], DigitBlock -> 3]
 }, {i,25,100}]

tab1804 = Prepend[tab1803, 
 {"n", "<= \[Pi](n)", ">= \[Pi](n)"}]

grid2 = Grid[tab1804, Frame -> All, ItemStyle -> "Text", 
 Background -> {{LightGray, None}, {LightGray,None}}]
showit


tab1106 = Table[{HoldForm[10]^i, 
 NumberForm[bounds[10^i][[1]], DigitBlock -> 3],
 NumberForm[actval[i], DigitBlock -> 3],
 NumberForm[bounds[10^i][[2]], DigitBlock -> 3],
 N[(actval[i]-bounds[10^i][[1]])/(bounds[10^i][[2]]-bounds[10^i][[1]])]
 }, {i,3,24}]

tab1107 = Prepend[tab1106, 
 {"n", "\[Pi](x) lower bound", "\[Pi](x)", "\[Pi](x) upper bound", "Whence"}]

tab1107 = Prepend[tab1106, 
 {"n", "<= \[Pi](n)", "\[Pi](n)", ">= \[Pi](n)", "Whence"}]

grid = Grid[tab1107, Frame -> All, ItemStyle -> "Text", 
 Background -> {{LightGray, None}, {LightGray,None}}]
showit

grid = Grid[tab1107, Frame -> All]

grid = Grid[tab1107, Frame -> All]

PrimePi[x]

\[Sigma]
\[Sigma][x]
"\[Sigma](x)"


The, integer [note the middle int + why its not great]



LogIntegral[x]-range[x] < PrimePi[x] < LogIntegral[x]+range[x]

LogIntegral[x]+range[x] < HoldForm[10^48]

LogIntegral[x]-range[x] > HoldForm[10^48]


LogIntegral[n2]+range[n2] 


x-y < z

or x< z+y

y-x<z or -x < z-y or x > y-z

y-z < x < y+z


ili[x_] := t /. FindRoot[LogIntegral[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]

range[x_] = Log[x]*Sqrt[x]/8/Pi

ili2[x_] := Ceiling[t /. FindRoot[LogIntegral[t]+range[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]]

n2 = 114253594378425466185102853920130817319525886680867-1

LogIntegral[n2]+range[n2] > 10^48 and none smaller

ili3[x_] := Floor[t /. FindRoot[LogIntegral[t]-range[t] == x, {t,x*Log[x]}, 
 WorkingPrecision -> Log[x], AccuracyGoal -> Log[x], PrecisionGoal -> Log[x]]]

n3 = 114253594378425466185114154511712329201522001657687

Floor[LogIntegral[n3]-range[n3]]

LogIntegral[n3]-range[n3] < 10^48 and is largest such

https://oeis.org/A006988
https://oeis.org/A006988/b006988.txt


Using Mathematica, we find that 114253594378425466185108504215921573260523944025925 (114,253,594,378,425,466,185,108,504,215,921,573,260,523,944,025,925) is the integer n such that li(n) is closest to [math]10^{48}[/math].

n2 = 114253594378425466185102853920130817319525886680866

n2 = 114253594378425466185108553237030328694398437471430

N[LogIntegral[n2]-range[n2],53]


[math]

|x-y| < z



AccountingForm[N[LogIntegral[n-1],53], DigitBlock -> 3]               


with the following property:

[math]10^{48}-1 < \text{li}(n) < 10^{48} < \text{li}(n+1)[/math]

Computing [math]\frac{\sqrt{n} \log (n)}{8 \pi }[/math] to the nearest integer yields 49021108755433879077126144 (49,021,108,755,433,879,077,126,144). If we call this m, we have:

[math]\left| \pi (n)-\text{li}(n) \right|< m[/math]








Round[N[range[n]],1]






N[LogIntegral[n],53] // AccountingForm



NumberForm[n, DigitBlock -> 3]                                         

n = Rationalize[ili[10^48],1]+1

N[LogIntegral[n],53] // AccountingForm

Abs[PrimePi[x] - LogIntegral[x]] < range[x]                            

http://www.jstor.org/stable/2005976?origin=crossref&seq=1#page_scan_tab_contents 



(* inverse logintegral function of sorts *)






FindRoot[LogIntegral[t] == 10^48, {t,10^48*Log[10^48]},  
 WorkingPrecision -> 50, AccuracyGoal -> 50, PrecisionGoal -> 50]

 





Plot[LogIntegral[x],{x,0,1000}]


https://www.quora.com/What-is-the-10-48th-prime-number

https://en.wikipedia.org/wiki/Prime-counting_function

|pi(x) - li(x)| < 1/(8*pi)*log(x)*sqrt(x)

Integrate[1/Log[t],{t,0,x}]

LogIntegral is mathematica's name

Solve[LogIntegral[x]-2 == 10^48, x]

Plot[LogIntegral[x]-2,{x,10,1000}]

LogPlot[LogIntegral[x]-2,{x,10,10^48}]

LogPlot[LogIntegral[x]-2,{x,10,10^51}]

FindRoot[LogIntegral[x]-2-10^48,{x,10^48,10^52}]


FindRoot[LogIntegral[x]-2-10^48,{x,1.14*10^50,1.15*10^50}]

1.1425359437842517`*^50


LogIntegral[1.1425359437842517*10^50]-10^48

Solve[Log[LogIntegral[x]-2] == Log[10^48], x]

Plot[LogIntegral[x], {x,10^50,2*10^50}]

Plot[LogIntegral[x], {x,1.1*10^50,1.15*10^50}]

FindRoot[LogIntegral[x]-2-10^48,{x,Rationalize[1.14*10^50],
 Rationalize[1.15*10^50]}]

LogIntegral[Rationalize[1.14254*10^50,0]]

FindRoot[LogIntegral[x]-2-10^48,{x,Rationalize[1.142*10^50,0],
 Rationalize[1.143*10^50,0]}, Method -> Brent, PrecisionGoal -> 100,
 AccuracyGoal -> 100]

findroot2[LogIntegral[#]-10^48 &,1.14*10^50,1.15*10^50, 1]

Plot[LogIntegral[x], {x,1.1*10^50,1.15*10^50}]

Plot[LogIntegral[x], {x,1.14*10^50,1.15*10^50}]

FindRoot[LogIntegral[x] == 10^48, {x,10^50}]


FindRoot[LogIntegral[x] == 10^48, {x,1.14254*10^50}, PrecisionGoal -> 50,
 AccuracyGoal -> 50, WorkingPrecision -> 50]

test = 114253594378425466185108504215921573260523944025924

N[LogIntegral[test], 500]

|pi(x) - li(x)| < 1/(8*pi)*log(x)*sqrt(x)

Log[test]*Sqrt[test]/8/Pi

range = 49021108755433874493445505

114253594378425466185108455194812817826649450580733
114253594378425466185108553237030328694398437471393


TODO: https://oeis.org/A276473 counts A202259

(* bounds for number of A202559 given at least 3 primes for n digit *)

b[n_] = RSolve[{a[0] == 5, a[n+1] == a[n]*10-3}, a[n], n][[1,1,2]];

b[n_] = RSolve[{a[0] == 5, a[n+1] == a[n]*10-3}, a[n], n][[1,1,2]];


FullSimplify[LogIntegral[E^2]]
