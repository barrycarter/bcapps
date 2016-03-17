pop2 = Table[{i[[1]], i[[2]]/10^9}, {i,pop}];
lin[x_] = Fit[pop2, {1,x}, x]

lp = ListPlot[pop2,   PlotLabel -> "World population (billions)",
 PlotMarkers -> Graphics[{RGBColor[1,0,0], PointSize -> 0.01, Point[{0,0}]}]];
linx = Plot[lin[x],{x,1950,2050}, AxesOrigin -> {1950,lin[1950]}];

Show[{linx, lp}]
showit

census = Partition[{
 1435708800, 7256490011,
 1438387200, 7263120419,
 1441065600, 7269750827,
 1443657600, 7276167351,
 1446336000, 7282797759,
 1448928000, 7289214283,
 1451606400, 7295844691,
 1454284800, 7302475099,
 1456790400, 7308677739,
 1462060800, 7321724671,
 1467331200, 7334771614
}, 2]

cen2=Table[{(i[[1]]-1435708800)/(1467331200-1435708800)+2015,
 i[[2]]/10^9},{i,census}]

lp3 = ListPlot[cen2,   PlotLabel -> "World population (billions)",
 PlotMarkers -> Graphics[{RGBColor[1,0,0], PointSize -> 0.01, Point[{0,0}]}]];

lin2[x_] = Fit[cen2,{1,x},x]

linx2 = Plot[lin2[x] ,{x,2015,2016}]

Show[{linx2, lp3}]
showit

linx3 = Plot[lin2[x] ,{x,1950,2050}, AxesOrigin -> {1950, lin2[1950]}]

Show[{linx3,lp}]

Show[{linx,Graphics[{RGBColor[1,0,0],pop2}]}]

(*

@Andrew_D._Hwang's answer is absolutely correct, and these are just
possibly helpful notes that are too long for a comment.

The US Census Department has a world population clock:

http://www.census.gov/popclock/?intcmp=home_pop

I was hoping they used a formula to compute this (which would tell us
whether the Census Dept believes growth is exponential, linear, etc),
but it turns out they don't:

http://reverseengineering.stackexchange.com/questions/12229

You can also look at the historical and predicted world population here:

https://www.census.gov/population/international/data/worldpop/table_population.php

which fits the line $0.0737374 x-141.441$ (in billions, where x is the
year number) surprisingly well:

[[image5.gif]]

Of course, this is just putting a straight line through someone else's
estimate, not making your own estimate.

To make your own estimates, you could try various formulas to fit the
1950-2015 data, or, if you believe the population growth rate has
changed fundamentally since 1950, a shorter period of time, such as
2000-2015.

If you accept the Census' short-term population
estimates/projections, available in JSON form at:

https://www.census.gov/popclock/data/population.php/world

you'll find the line $0.0782816 x-150.481$ fits quite well:

[[image6.gif]]

(note that, to the Census Department, 2015 means the middle of the year 2015).

although using this line for longer-term historical and projected data
doesn't work as well:

[[image7.gif]]

So, to a good approximation, you can say the world population is
growing linearlly, both short-term and long-term, but at slightly
different rates.

Of course, if you look at **any** reasonable function over a short
enough time period, it will look linear, so the analysis above is
somewhat biased.

If you want to look longer-term, you might consider using 12,000 years
worth of estimates:

https://www.census.gov/population/international/data/worldpop/table_history.php

Ultimately, it depends on how you define "most recent history" and how
you plan to use the approximation.

EDIT: Well, since you gave me the checkmark, let me add a couple of things.

As @Andrew_D._Hwang notes, there are many models of population growth.

Perhaps the simplest one is the
https://en.wikipedia.org/wiki/Malthusian_growth_model which assumes
that, on average, each person alive today will give birth to k
children. Of course, in our species, only females give birth, but this
is just an average number of the entire population.

This model leads to exponential growth, which caused quite a bit of
concern in the 80s and 90s, since exponential growth is
unsustainable. Even well-respected science fiction author Isaac Asimov
was deeply concerned:

https://asimovfan.wordpress.com/2013/05/09/asimovs-malthusianism/

Though it's not in the source above, he believed humanity would fill
up the galaxy (not just Earth) within 6000 years.

It turns out this model isn't very realistic. The logistic equation
@Andrew_D._Hwang mentions
(https://en.wikipedia.org/wiki/Logistic_function) also known as the
Verhulst-Pearl equation, postulates that any time two people meet,
there is a constant, small, but non-zero chance that one will kill the
other.

The number of such encounters is proportional to the total number of
ways in which 2 people can meet each other, $\frac{1}{2} (p-1) p$,
which is about $\frac{p^2}{2}$.

In this equation, the population still increases by the birth rate
above, but also decreases by $b p^2$ due to people killing each other,
for some constant $b$.

This Verhulst-Pearl equation ultimately yields a constant population
with zero growth.

I don't know of any model that shows long-term linear growth (but that
might just be me: when I was growing up, the two models above were the
most popular), so the linear model really is short-term and won't
last.

Of course, the Sun will ultimately go nova, after which the Earth's
living human population will probably be 0, so, in some sense, it's
all a matter of time scales.

Other resources:

http://www.zo.utexas.edu/courses/Thoc/PopGrowth.html

http://www.sosmath.com/diffeq/first/application/population/population.html

http://www.nature.com/scitable/knowledge/library/how-populations-grow-the-exponential-and-logistic-13240157

