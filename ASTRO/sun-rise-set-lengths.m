TODO: answer here!

To an accuracy of $0.05 {}^{\circ}$, the Sun's average declination at 12h UT on the nth day of the year for the years 2000-2099 inclusive is:

$
  0.0697459 \sin \left(\frac{\pi  n}{183}\right)+0.000529317 \sin \left(\frac{2
    \pi  n}{183}\right)+0.00131974 \sin \left(\frac{\pi  n}{61}\right)-0.400316
    \cos \left(\frac{\pi  n}{183}\right)-0.0060873 \cos \left(\frac{2 \pi 
    n}{183}\right)-0.00239961 \cos \left(\frac{\pi  n}{61}\right)+0.00576798
$

where all angles are measured in radians.

I obtained the formula above via curve fitting because I was unhappy with Wikipedia's [solar declination formulas](https://en.wikipedia.org/wiki/Position_of_the_Sun#Calculations), and believe the "more accurate" formula is actually incorrect.

My formula is unnecessarily precise, because there is no exact formula mapping day of year to solar declination. Example:

  - On the 240th day of 2017 (August 28th, Julian Day 2457994), the sun's declination at 12h UT is 0.168035 radians (9.6277 degrees).

  - On the 240th day of 2018 (August 28th, Julian Day 2458359), the sun's declination at 12h UT is 0.169625 radians (9.7188 degrees).

  - On the 240th day of 2019 (August 28th, Julian Day 2458724), the sun's declination at 12h UT is 0.171204 radians (9.80927 degrees).

  - On the 240th day of 2020 (August 27th [because 2020 is a leap year], Julian Day 2459089), the sun's declination at 12h UT is 0.172757 radians (9.89825 degrees).

That's a range of 0.27055 degrees over just 4 years.

A celestial object reaches altitude `alt` at:

$
   \cos ^{-1}(\sin (\text{alt}) \sec (\text{dec}) \sec (\text{lat})-\tan
    (\text{dec}) \tan (\text{lat}))
$

after it culminates, where all angles are in radians. Notes:

  - The result is in radians, where $2 \pi$ radians is a sidereal day.

  - If the value inside the arc-cosine function is greater than 1 or less than -1, the object never reaches the given altitude.

  - Setting 

TODO: twilights





TODO: time in radians

TODO: apprxomation


TODO: my other ugly formula URL
sidereal to solar conversion




REF: http://aa.usno.navy.mil/jdconverter?ID=AA&jd=2457994


TODO: variance



how I got these numbers

bc-equator-dump 10 399 2000 2100
mention bc-astro-formulas.m mention


dec avg is not 0!
