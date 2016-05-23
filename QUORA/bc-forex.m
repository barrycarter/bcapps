(*

Blog entry about FOREX on quora (or wherever) w/ actual trades?

TODO: brits have more options (vanilla)

TODO: major disclaimers

TODO: mention NADEX limits

TODO: why GBPUSD

TODO: laziness of USD/* (not doing it)

TODO: fake money + down on US = bad?

TODO: general strategy with math after main section

TODO: nadex vol not real?

TODO: except for nadex, chosen are not recommendations

TODO: rollover rates

TODO: some banks offer NADEX directly

TODO: citibank fx = FDIC protected, others not?

TODO: oanda box options?

TODO: combination of scaling down (investors dislike) + covered calls 
(investors like) [scale trading]

TODO: 5m binaries on NADEX! (but useless?)

TODO: format for quora on in general for markup

TODO: currently using "**" for super-bold; but change this to actual quora format later

TODO: calc disclaimer (my error)

TODO: leverage/low margin

TODO: read long list of disclaims at end please

TODO: disclaim current value is 21 May 2016ish

TODO: summary of strategy (include 36 pip example)

TODO: rec min $100K or adjust

  - Because we'll be using nadex.com (TODO: why!) for binary options, look
  at https://www.nadex.com/markets/forex for the list of binary
  options you can trade on NADEX:

    - EUR/USD
    - AUD/USD
    - EUR/GBP
    - GBP/USD
    - USD/CAD
    - AUD/JPY
    - USD/JPY
    - GBP/JPY
    - EUR/JPY
    - USD/CHF

and, through additional research (eg, xe.com, fxtop.com, oanda.com or
some other site that provides or charts historical currency rates),
find a pair that you feel won't drop more than 10%.

**IMPORTANT: If the currency pair you choose drops 10% or more , you
will lose everything you invested AND POSSIBLY MORE. If you feel ALL
of these currency pairs could drop 10% or more, THIS STRATEGY IS NOT
FOR YOU.**

  - To me, GBP/USD (the British pound vs the US dollar) looks good,
  since the last time it was 10% below its current value of 1.4569 was
  in mid-1986, about 30 years ago.

[[gbpusd-long.png]]

Of course, this isn't a perfect choice (none of the pairs are), since
GBP/USD has gone as low as 1.0438, 28% below it's current value.

However, my feeling (which could be very wrong) is that GBP/USD won't
decrease more than 10% in the next 2-3 years or so.

  - The first part of our strategy involves buying GBP/USD at every
  0.25% change in price, or every multiple of 36 pips. In other words,
  we want to buy GBP/USD at 1.4544 because 36*404 = 14544 (note that
  me multiply the price by 10,000 to get the price in
  pips). Similarly, we will want to buy GBP/USD when the price drops
  or increases to any other multiple of 36 pips such as:

  - 1.4400
  - 1.4436
  - 1.4472
  - 1.4508
  - 1.4544 (as noted above)
  - 1.458
  - 1.4616
  - 1.4652
  - 1.4688

and so on.

  - What happens if GBP/USD does drop 10%? If we invest $35,000 at
  each 36-pip multiple (0.25%), we will have 40 investments of $35,000
  each or a total investment of $1,400,000. Our loss on our first
  (highest priced) investment will be 10%, and our loss on our most
  recent (lowest price) investment will be 0% (since we've purchased
  it at the point where the 10% drop occurred), so our average loss
  will be 5% of $1,400,000 for a total loss of $70,000.

  - We will need an additional 2% margin of $28,000 to hold the
  $1,400,000 position, so our initial total deposit must be at least
  $98,000.

  - If you have less (or more) than $98,000 to invest, there are
  several ways to modify this strategy, but I am using $98,000 as the
  example, and the strategy way work even more poorly with less
  money. Ways to modify the strategy (make sure you understand the
  strategy and confirm your modification is still profitable):

    - Instead of investing $35,000 at each 0.25% (36 pip) change,
    invest a different amount.

    - Instead of investing at every 0.25% change, invest at every
    0.40% (or some other percentage) change.

    - Instead of buying at every 0.25% change all the way down to -10%
    (for 40 positions total if GBP/USD loses 10%), only buy down to
    -5% (20 positions total), but still be prepared for a 10% loss in
    GBP/USD.

    - Of course, you can choose a pair other than GBP/USD.

    - You may want to choose a safety margin larger than 10%, but I
    don't recommend choosing one smaller than 10%.

  - Now, suppose you buy at 1.4472 and end up selling at 1.4675 (just
  as an example). How much profit would you have made? Since
  1.4675/1.4472 is 1.014, you might expect a profit of about 1.4% of
  $35,000, which is $490.95. Let's see how this works:

    - When you buy $35,000 worth of GBP/USD at 1.4472 you get
    35000/1.4472 or 24184.63 GBP in exchange for 35000.00 USD.

    - When you sell your 24184.63 GBP at 1.4675, you get back 35490.94
    dollars, for the $490.95 profit noted above.

    - In other words, you made $490.95 for a 203 pip (that's
    (1.4675-1.4472)*10000) change in the market, or about $2.42 per
    pip. The exact profit/loss per pip will vary as the price changes,
    but $2.42 is a reasonable estimate for right now.

  - How do options enter the picture? If you look at NADEX's weekly
  options, you see:

[[Nadex.com_1464024762227]]

If you sell the 1.4675 option at the bid price (which you never
actually want to do), you will receive $13.75, but will lose $100 if
GBP/USD goes above 1.4675.

Because NADEX charges $1 in commission each direction (fees may have
changed, please doublecheck before investing) you will actually get
$12.75 and lose $101 if GBP/USD goes above 1.4675.

Since you get to keep the $12.75 either way, you are risking $88.25
(that's 101.00 minus 12.75) per contract.

  - Now, suppose you sell 5 of these options for a total of $12.75*5
  or $63.75 profit. As long as GBP/USD remains below 1.4675, this
  money is yours to keep. If GBP/USD goes above 1.4675, you will lose
  $88.25*5 or $441.25. However, you will have made $490.95 on GBP/USD
  itself (as above), so you still come out ahead.

  - Of course, if GBP/USD falls 100 pips, you will have lost about
  $242.00, and the $63.75 profit you gain from NADEX won't be
  sufficient to cover this loss, so this strategy is not risk-proof.

  - If GBP/USD does fall 100 pips, you will have also already bought
  more of it and be selling options on those positions as well.



TODO: corner case rules

TODO: vanilla and saxo/gmx links

TODO: other options exist

TODO: not market orders

TODO: NADEX fees may've changed, bad spreads




*)
