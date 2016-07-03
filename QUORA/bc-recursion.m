(* https://www.quora.com/How-would-you-solve-this-series-problem *)

(*

This doesn't answer your question.

As others have noted, it doesn't appear that the limit of this sequence has a well-known closed form. The sequence converges fairly rapidly, and the 100th, 101st, and 200th iteration all have the same first 100 digits, so I'm reasonably confident that the first 100 digits of the answer are:

2.401615526026297355671587971656109034016639552161016527027633818278874921157513254553304977301472976

Neither the standard nor advanced version of http://isc.carma.newcastle.edu.au/index recognizes this (I used only the first few digits to get better matches) or several variants of this), and neither do several search engines (I used a meta-search engine to confirm this).

If you replace the number '4' with 'x' and plot the results of 100 iterations (which is effectively the final answer), you get:

[[image11.gif]]

As expected, it looks pretty much like the square root function.

If you plot it very close to 0, however, it looks more like a straight line:

[[image12.gif]]

with a y-intercept of 1.

Interestingly, as [math]x \to 0[/math], the slope of the line approaches [math]e - 2[/math], where [math]e[/math] is Euler's number, although this may just be a coincidence. For those interested, my work on this problem is here: https://github.com/barrycarter/bcapps/blob/master/QUORA/bc-recursion.m

*)

MENTION THIS FILE!







(* note m is the "4" here *)

seq[n_,m_] := Module[{v,i},
 v = m^(1/n);
 For[i=n-1, i>=2, i--,
  v = (m+v)^(1/i)];
 Return[v];
];

Plot[N[seq[100,x]],{x,0,50}, PlotRange -> All]


Plot[N[(seq[100,x]^2-1)/x],{x,0,100}, PlotRange -> All]                


Plot[N[(seq[100,x]^2-1)/x],{x,0,1}, PlotRange -> All]                

Plot[N[(seq[100,x]^2-1)/x-1],{x,0,10}, PlotRange -> All]

Plot[N[1/((seq[100,x]^2-1)/x-1)],{x,0,10}, PlotRange -> All]


Plot[N[seq[100,x]-Sqrt[x]], {x,0,100}, PlotRange -> All]

Plot[N[(seq[100,x]^2-1)/x+4-2*E],{x,0,10}, PlotRange -> All]

Plot[N[1/((seq[100,x]^2-1)/x+4-2*E)],{x,0,10}]

Plot[N[-((seq[100,x]^2-1)/x+4-2*E)/Sqrt[x]],{x,0,10}, PlotRange -> All]

tab1317 = Table[{x,((seq[100,x]-1)/x-E+2)^4/x},{x,0.01,10,.01}];
ListPlot[tab1317]
showit

tab1317 = Table[{x,seq[100,x]},{x,.01,10,.01}];

tab1317 = Table[{x,seq[100,x]},{x,1,100,.01}];
Fit[tab1317, {1,Sqrt[x],x}, x]

Fit[tab1317, {1,Sqrt[x],Log[x],x}, x]

tab1317 = Table[{x,seq[100,x]-Sqrt[x]},{x,1,100,.01}];
Fit[tab1317, {1,Log[x]}, x]

tab1317 = Table[{seq[100,x],x},{x,.01,100,.01}];
tab1317 = Table[{seq[100,x],Sqrt[x]/x},{x,.01,100,.01}];
tab1317 = Table[{seq[100,x],1-1/Sqrt[x]},{x,1,100,.01}];
tab1317 = Table[{seq[100,x],Sqrt[x]},{x,1,10,.01}];

Fit[tab1317, {1,x}, x]

ListPlot[tab1317, PlotRange -> All]
showit

f1330[x_] = Fit[tab1317, {1,Sqrt[x],x,x^2}, x]

f1333[x_] = Fit[tab1317, {1,x,x^2}, x]

f1333[x_] = Fit[tab1317, {1,x^-1,x^-2,x^-3}, x]

Plot[{f1333[x]-seq[100,x]},{x,0,10}]
showit

tab1338 = Table[{x,seq[100,x]},{x,1,10,.01}];
ListPlot[tab1338]
showit



N[2*E,20]-4




((1^(1/9) + 4)^(1/8) + 4)^(1/7) + ...


Solve[(4+y)^(1/n) == y, y]

Solve[(4+y)^(1/14) == y, y]

Out[36]//InputForm= {{y -> Root[-4 - #1 + #1^14 & , 2, 0]}}



Clear[a]
a[2] = c;
a[n_] := a[n] = a[n-1]^(n-1) - 4

RSolve[a[n] == a[n-1]^(n-1) - 4, a[n], n]

RSolve[a[n] == a[n-1]^(n-1) - 0, a[n], n]


y(n) = nth root of 4+y(n+1)

y(2) = answer

y(2) = Sqrt[4+y(3)]

y(n) = (4+y(n+1))^(1/n)

y(n)^n - 4 = y(n+1)

y[2] = c;

y[n_] := y[n] = y[n-1]^(n-1)-4

z[50] = 1+epsilon;

z[n_] := (4+z[n+1])^(1/n)

Log[y[n]] == Log[4+y[n+1]]/n




4^(1/2)

(4 + 4^(1/3))^(1/2)

(4+(4+4^(1/4))^1/3)^1/2

(4+4^(1/n))^(1/(n-1))


a[n_] := Module[{v,i},
 v = 4^(1/n);
 For[i=n-1, i>=2, i--,
  v = (4+v)^(1/i)];
 Return[v];
];


tab0929 = Table[Log[a[n+1]/a[n]], {n,2,100}];


b[n_] := Module[{v,i},
 v = 2^(1/n);
 For[i=n-1, i>=2, i--,
  v = (2+v)^(1/i)];
 Return[v];
];


