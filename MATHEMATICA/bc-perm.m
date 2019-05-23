(*

find the permutation with the biggest distance between elements

*)


t2355 = Range[1, 10]

t2356 = Permutations[t2355, {5}]

diffNorm[list_] := 
 Total[Table[(list[[i]] - list[[i-1]])^2, {i,2,Length[list]}]]

t2359 = Map[diffNorm, t2356];

Max[t2359] is 245

Select[t2356, diffNorm[#] == 245 &]

Out[37]= {{2, 10, 1, 9, 3}, {3, 9, 1, 10, 2}, {8, 2, 10, 1, 9}, 
 
>    {9, 1, 10, 2, 8}}

diffNorm[list_] := 
 Total[Table[(list[[i]] - list[[i-1]])^2, {i,2,Length[list]}]]

f[n_] := Max[Map[diffNorm, Permutations[Range[1,n]]]]

numbers are: f(2) = 1, 5, 17, 35, 65, 105, 161, 231, 321

list1 = {1, 5, 17, 35, 65, 105, 161, 231, 321}

both above its Differnces are not known to OEIS

absNorm[list_] := 
 Total[Table[Abs[list[[i]] - list[[i-1]]], {i,2,Length[list]}]];

g[n_] := Max[Map[absNorm, Permutations[Range[1,n]]]]

In[20]:= Table[g[i], {i, 1, 10}]                                                
Out[30]= {0, 1, 3, 7, 11, 17, 23, 31, 39}

then 49

http://oeis.org/A047838

Table[Floor[n^2/2]-1, {n, 1, 15}]

Define the organization number of a permutation pi_1, pi_2, ..., pi_n to be the following. Start at 1, count the steps to reach 2, then the steps to reach 3, etc. Add them up. Then the maximal value of the organization number of any permutation of [1..n] for n = 0, 1, 2, 3, ... is given by 0, 1, 3, 7, 11, 17, 23, ... (this sequence). This was established by Graham Cormode (graham(AT)research.att.com), Aug 17 2006, see link below, answering a question raised by Tom Young (mcgreg265(AT)msn.com) and Barry Cipra, Aug 15 2006

h[n_] := Select[Permutations[Range[1,n]], absNorm[#] == Floor[n^2/2]-1 &]

h[2] and up

{1, 2}

{1, 3, 2}

{2, 4, 1, 3}

{2, 4, 1, 5, 3}

{3, 5, 1, 6, 2, 4}

{3, 5, 1, 6, 2, 7, 4}

{4, 6, 1, 7, 2, 8, 3, 5}

guessing

{4, 6, 1, 7, 2, 8, 3, 9, 5} and that works

guessing

{5, 7, 1, 8, 2, 10, 9, 3, 4, 6}

39 is absnorm there which is no bigger than previous

ok given

{4, 6, 1, 7, 2, 8, 3, 9, 5} has absnorm 39 and we want 10 more

{4, 6, 1, 7, 2, 10, 8, 3, 9, 5} has absnorm 39 and we want 10 more FAIL

{1,3,2} is 3 and we want 7 next.. can we insert?

nope

what about 11 if we go 2 up and add 4 and 5

Maximize[{Abs[a1-a0] + Abs[a2-a1] + Abs[a3-a2], 
 a0 > 0, a0 < 1, a1 > 0, a1 < 1, a2 > 0, a2 <1, a3 > 0, a3 < 1},

{a0, a1, a2, a3}
]

Maximize[{(a1-a0)^2 + (a2-a1)^2 + (a3-a2)^2, 
 a0 > 0, a0 < 1, a1 > 0, a1 < 1, a2 > 0, a2 <1, a3 > 0, a3 < 1},

{a0, a1, a2, a3}
]

Out[66]= {3, {a0 -> 0, a1 -> 1, a2 -> 0, a3 -> 1}}

same for other one

Maximize[{Abs[a1-a0] + Abs[a2-a1] + Abs[a3-a2], 
 {a0, a1, a2, a3} == {1,2,3,4}},
{a0, a1, a2, a3}]

RandomSample[Range[48]]

t2334 = Table[RandomSample[Range[48]], {i, 1, 100000}];

t2335 = Map[absNorm, t2334];

1035 is max

Floor[48^2/2]-1

1151 is highest possible not bad

Out[85]= {{32, 1, 24, 14, 47, 20, 8, 34, 17, 41, 10, 36, 27, 13, 37, 2, 25, 16, 
 
>     29, 9, 42, 7, 23, 30, 15, 38, 12, 21, 22, 39, 4, 35, 28, 46, 18, 6, 31, 
 
>     5, 40, 26, 43, 44, 3, 48, 11, 45, 19, 33}}



start with {1, 3, 2, 4} + ask about beneficial swaps

{1, 3, 2, 4} -- swapping 1 and 3 doesn't change anything (2+1 vs 2+1)

swapping 3 and 2 actually hurts (1+1 vs 2+1)

swapping 2 and 4 doesnt help either

(*

Find permutation with highest organization number (OEIS A047838)

<pre><code>

(*

http://oeis.org/A047838 defines the "organization number" of a permutation as:

Define the organization number of a permutation pi_1, pi_2, ..., pi_n
to be the following. Start at 1, count the steps to reach 2, then the
steps to reach 3, etc. Add them up. Then the maximal value of the
organization number of any permutation of [1..n] for n = 0, 1, 2, 3,
... is given by 0, 1, 3, 7, 11, 17, 23, ... (this sequence).

The phrase "organization number" appears to be nonstandard, but I'll
continue to use it in this question.

In Mathematica, the organization number of a permutation would be:

*)

orgNumber[list_] := 
 Total[Table[Abs[list[[i]] - list[[i-1]]], {i,2,Length[list]}]];

(*

Of course, that works for any list, not just permutations.

The OEIS link above provides a formula for the highest possible
organization number for a permutation of n elements:

*)

maxOrg[n_] = Floor[n^2/2]-1

(*

My question: how can I find a permutation of n elements whose
organization number is maximal. For n > 1, there will always be at
least 2 such permutations (since the reverse permutation has the same
organization number), and, from what I've seen, there are usually
several. I just want to find one of them.

For small values of n, you can brute force it:

*)

maxPerm[n_] := Select[Permutations[Range[1,n]], orgNumber[#] == maxOrg[n] &]

(*

but this gets really slow after about n=10

I looked at the "first" permutation meeting this condition for each
value of n=2 through n=8  and got:

{1, 2}
{1, 3, 2}
{2, 4, 1, 3}
{2, 4, 1, 5, 3}
{3, 5, 1, 6, 2, 4}
{3, 5, 1, 6, 2, 7, 4}
{4, 6, 1, 7, 2, 8, 3, 5}

Going from an even number to an odd number seems to follow an obvious
pattern, so I correctly guessed the following for n=9:

{4, 6, 1, 7, 2, 8, 3, 9, 5}

However, I couldn't find enough of a pattern to find a value for n=10.

In my "real world" application, n = 44, so brute forcing is not an option.

However, I did use:

*)

t0 = Table[RandomSample[Range[44]], {i, 1, 100000}];

t1 = Max[Map[orgNumber, t0]]

(*

Obviously, results will vary, but I got t1 = 885. Since the max
possible is 967, this is a pretty good value (and I get the
permutation(s) matching this number using Select, as above), but,
obviously, I'd prefer the true max.

Another interesting question would be: what's the distribution of
organization numbers for a given n.

Based on my random experimentation, the distribution appears to look
somewhat Normal, with a mean of n^2/3. I wasn't able to get a real
feeling for the standard deviation, though it appears to be about 59.6
for n=44

*)

(* post neil and mathematica.stack *)

list[n_] := Map[orgNumber, Table[RandomSample[Range[n]], {i, 1, 100000}]];

mean[n_] := Mean[list[n]]

sd[n_] := Sqrt[Variance[list[n]]]

t1446 = Table[{n, mean[n], sd[n]}, {n, {15, 20, 25, 30, 35}}]

(* below from SE question *)

k=44;

r=Last@Select[Flatten[Table[Select[Riffle[#,-Last@IntegerPartitions[Floor[(Floor[k^2/2]-1)/2],{Floor[(k-1)/2]},b=Range[s=Floor[Floor[(Floor[k^2/2]-1)/2]/Floor[k/2]],s+2]]]&/@Reverse/@IntegerPartitions[Floor[(Floor[k^2/2]-1)/2]+1,{Ceiling[(k-1)/2]},Range[s,s+k-8]],Union[FoldList[Total[{##}]&,p,#]]==Range@k&],{p,k}],1],Union@Differences@Union[FoldList[Total[{##}]&,#[[1]],#]]=={1}&];w=FoldList[Total[{##}]&,1,r];

f=w+k-Max@w

Total@Abs@Differences@f

Floor[k^2/2]-1    

{22,44,21,43,20,42,19,41,18,40,17,39,16,38,15,37,14,36,13,35,12,34,11,33,10,32,9,31,8,30,7,29,6,28,5,27,4,26,3,25,2,24,1,23}

TODO: understand above, circular data, find perm with max min diff

data also circular in mod sense {7, 1} distance in mod 8 is 2, not 6




