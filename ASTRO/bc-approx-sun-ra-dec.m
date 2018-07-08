(*

Uses the output of:

bc-equator-dump-2 10 399 2000 2036

to find an approx formula for solar right ascension and declination
using equitorial coordinates of date

*)

data = Import["/home/barrycarter/20180708/sun-ra-dec.txt", "Data"];

ListPlot[difference[Transpose[data][[3]]]]

ListPlot[difference[Take[Transpose[data][[3]], 10000]]]

superfour[Transpose[data][[3]], 2]




In[24]:= FromJulianDate[data[[1,2]]]

Out[24]= DateObject[{2000, 1, 1, 12, 0, 0.}, Instant, Gregorian, 0.]









