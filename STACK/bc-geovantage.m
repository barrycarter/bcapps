(*

https://politics.stackexchange.com/questions/6286/is-it-true-that-republicans-have-an-unfair-geographical-advantage-in-elections-f

Summary: It's complicated. Results from the 2012 and 2006 elections show that, statistically, Democrats should have won all the seats, but results from the 2000 and 1994 elections show the Republicans should have won most (in 2000) or all (in 1994) of the seats. The problem cannot be resolved via simple statistical analysis (below).

According to https://en.wikipedia.org/wiki/United_States_House_of_Representatives_elections,_2012#Results_summary, of the 122,346,020 votes cast total, Democrats received 59,645,531 or 48.8% of the vote, Republicans received 58,228,253 or 47.6% of the vote, and the remaining 4,472,236 or 3.7% of the votes went to other candidates (%ages don't add to 100% due to rounding).

If Democrats received 48.8% of the vote in every district, and Republicans received 47.6% of the vote in every district, the Democrats would've won every seat.

However, probability doesn't work that way. If you flip a fair coin 100 times, it's highly unlikely to get exactly 50 heads: there's a 95% chance you'll get between 40 and 60 heads, a 99.5% chance you'll get between 30 and 70 heads, but there's even a small chance (0.5%) that you'll get fewer than 30 or more than 70 heads.

Let's apply this methodology (called the "binary distribution") to the problem at hand.

Because the binary distribution only applies when there are two choices, let's consider only major party (Democratic and Republican) votes. In this scenario:

  - There are a total of 117,873,784 cast for major parties.

  - Republicans received 58,228,253 or 49.40% of these votes

  - Democrats received the remaining 59,645,531 or 50.60% of these votes.

Let's now consider the House district with the fewest number of votes. According to http://uselectionatlas.org/FORUM/index.php?topic=255728.0 and backed up by http://history.house.gov/Institution/Election-Statistics/2016election/, this appears to be Texas's 33rd district with 126,369 votes.

NOTE: I didn't look at every single number if the PDF, nor did I confirm the validity of https://docs.google.com/spreadsheets/d/1oArjXSYeg40u4qQRR93qveN2N1UELQ6v04_mamrKg9g/edit#gid=0, but the argument below works even if the number is relatively close.

With 126,369 votes, you need 63,185 votes to win.

If the districts were evenly populated with Democratic and Republican voters nationwide, you'd expect 49.40% or ~62,425 voters in this district to vote Republican. Of course, the chances of that happening exactly is very low, so we also calculate the standard deviation which happens to be 125 in this case.

What are the chances of a Republican win? Since 63,185 is 760 or about 6 standard deviations above the average, the chances of a Republican victory are about one in a billion.

The chances are even smaller in districts with more voters. With roughly even distribution of Democrats and Republicans, the chance of Republicans winning even one seat are less than 1 in 2.3 million.

The results of the 2006 election are even more convincing: https://en.wikipedia.org/wiki/United_States_House_of_Representatives_elections,_2006, since the Democrats won by a larger margin.

However, the results of the 2000 election (https://en.wikipedia.org/wiki/United_States_House_of_Representatives_elections,_2000) tell a different story. Without going through the gory math (available at https://github.com/barrycarter/bcapps/blob/master/STACK/bc-geovantage.m), the Democrats had only a 1.3% chance of winning a given district, so their winning 212 seats would be next to impossible, statistically speaking.

Going back even further: statistically, the Democrats had virtually no chance of winning a single seat in the 1994 election (https://en.wikipedia.org/wiki/United_States_House_of_Representatives_elections,_1994), but actually won 204 seats.

Ultimately, the problem goes deeper than statistics. You could run the numbers on a state-by-state basis (allowing for state bias towards a candidate), but there's no good reason to believe states are a fundamental unit of bias: bias could occur at the county level, urban vs suburban level, etc.

*)

TODO: proofread

So, allowing for random chance, the number of Republican votes we expect is:

(* this definition is necessary due to errors on brighton *)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {800, 600}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]

46,992,383
46,582,167



PDF[NormalDistribution[126369*

Plot[PDF[NormalDistribution[126369*58228253/117873784, 
 Sqrt[126369*58228253/117873784/4]]][x], {x,62000,64000}]

TODO: spell check

********* ERRORS IE POPULATED WITH MORE REPUB


Sqrt[126369*.25]

TODO: mention this file, mention bigg

http://uselectionatlas.org/FORUM/index.php?topic=255728.0

TX-33 (126K)

126,369

http://history.house.gov/Institution/Election-Statistics/2016election/


122,346,020

(*

apathy?

2016
R: 63,173,815
D: 61,776,554

2014
R: 40,081,282
D: 35,624,357

2012
R: 58,228,253
D: 59,645,531

2010
R: 44,827,441
D: 38,980,192

2008
D: 65,237,840
R: 52,249,491

2006
D: 42,338,795
R: 35,857,334

2004
R: 55,958,144
D: 52,969,786

2002
R: 37,332,552
D: 33,795,885

2000
R: 46,992,383
D: 46,582,167

********

order is R, D

elecs = {

{2016, 63173815, 61776554},
{2014, 40081282, 35624357},
{2012, 58228253, 59645531},
{2010, 44827441, 38980192},
{2008, 52249491, 65237840},
{2006, 35857334, 42338795},
{2004, 55958144, 52969786},
{2002, 37332552, 33795885},
{2000, 46992383, 46582167}

};

t = Table[{i[[2]]+i[[3]], i[[3]]/(i[[2]]+i[[3]])}, {i, elecs}]

126369 votes SD is 178 peeps or so

1/(2*Sqrt[x])

250K = 1/1000 or 0.1% exactly










*)
