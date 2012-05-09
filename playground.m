(* playground for Mathematica *)

showit := Module[{}, 
Export["/tmp/math.png",%, ImageSize->{800,600}]; Run["display /tmp/math.png&"]]

(* figuring out linear regression myself *)

(yi-(a*xi+b))^2

(* sum of squares for given line *)
diff[a_,b_] = Sum[(y[i]-(a*x[i]+b))^2,{i,1,5}]

(* Minimize, but below hangs Mathematica *)
Minimize[diff[a,b],{a,b}]

(* look for 0 derv *)
Solve[D[diff[a,b],a]==0, a]
Solve[D[diff[a,b],b]==0, b]
zd[a_] = b /. %[[1,1]] 

(* from above b == -a*(sumx) + (sumy) *)

Solve[D[diff[a,b],a]==0, a] /. b -> zd[a]


(* if you save $1/month at r% for y years... *)

m[t_,r_] = m[t,r] /.
DSolve[{D[m[t,r],t] == 12 + m[t,r]*r, m[0,r]==0}, m[t,r], {t,r}][[1]]

m[t_,0] = 12*t

t1 = Table[m[t,r],{t,1,40},{r,0,.24,.01}]

StringJoin[
Table["<td>"<>ToString[m[1,r]]<>"</td>",{r,0,.24,.01}]
]


mon[0] = 0
mon[n_] = mon[n-1] + 1 + r*mon[n-1]

RSolve[{
 mon[0] == 0,
 mon[n] == mon[n-1] + 1 + r*mon[n-1]},
mon[n],n]

RSolve[{
 mon[0] == 0,
 mon[n] == mon[n-1] + 1 + ((1+r)^(1/12)-1)*mon[n-1]},
mon[n],n]

(* credit card DFQ from bc-cc-interest.pl; see also http://stackoverflow.com/questions/4455575/find-equivalent-interest-rate-for-cash-advance-fee-promo-rate *)

(*

int = yearly interest charge on loan
min = minimum payment (per year) on loan
int2 = interest earned on borrowed money
amt = amount borrowed (but this is actually irrelevant)
fee = %fee charged for loan ("points")

*)

(* specific example from apr.barrycarter.info *)

t3 = DSolve[{
 owed[0] == 10000*1.03,
 have[0] == 10000,
 owed'[t] == (.04/12-.02)*owed[t],
 have'[t] == (.06/12)*have[t] - .02*owed[t]
}, {owed[t], have[t]}, t]

t2[t_] = owed[t] /. t3[[1]]
t4[t_] = have[t] /. t3[[1]]

Table[{t,t2[t]},{t,1,16}] // TableForm
Table[{t,t4[t]},{t,1,16}] // TableForm

(* generalizing slightly, and exactifying *)

t3 = DSolve[{
 owed[0] == 10000*103/100,
 have[0] == 10000,
 owed'[t] == (4/100/12-2/100)*owed[t],
 have'[t] == (r/12)*have[t] - 2/100*owed[t]
}, {owed[t], have[t]}, t]

Solve[have[16] == owed[16], r] /.
DSolve[{
 owed[0] == 10000*103/100,
 have[0] == 10000,
 owed'[t] == (4/100/12-2/100)*owed[t],
 have'[t] == (r/12)*have[t] - 2/100*owed[t]
}, {owed[t], have[t]}, t][[1]]

Solve[t2[16/12] == t4[16/12], r]

FindRoot[t2[16/12] == t4[16/12], {r,0,1}]

Solve[Exp[1/45]*t2[16/12] == Exp[1/45]*t4[16/12], r]

Series[Solve[t2[16/12] == t4[16/12], r],r, 10]

(* form that kills Math *)

Solve[r + Exp[r] + r*Exp[r] == 10, r]

Limit[r + Exp[r] + r*Exp[r], r->0]

Series[r + Exp[r] + r*Exp[r], {r,0,4}]

Solve[owed[t] == have[t], t] /.
DSolve[{
 owed'[t] == (int-min)*owed[t],
 have'[t] == int2*have[t] - min*owed[t],
 have[0] == amt,
 owed[0] == amt*(1+fee)
}, {owed[t], have[t]}, t]


t5 = DSolve[{
 owed'[t] == (int-min)*owed[t],
 have'[t] == int2*have[t] - min*owed[t],
 have[0] == amt,
 owed[0] == amt*(1+fee)
}, {owed[t], have[t]}, t]

t2[t_] = owed[t] /. t5[[1]]
t4[t_] = have[t] /. t5[[1]]

Normal[Series[t2[t], {int, 0, 2}]]
Normal[Series[t4[t], {int, 0, 2}]]

Normal[Series[t2[t], {int-min, 0, 2}]]


Solve[Normal[Series[t2[t], {int, 0, 2}]] ==
      Normal[Series[t4[t], {int, 0, 2}]], t]

t9[t_] = t4[t] /. Exp[x_] -> 1+x
t8[t_] = t2[t] /. Exp[x_] -> 1+x

Solve[t9[t]==t8[t], int2]

(* roughly int + fee*int + fee/t *)

(* so the extra interest is roughly fee/t*12 [12 for months] *)

t1[int_, min_, int2_, fee_] = t /. %[[1,1,1]]

t1[.36, .01*12, .02*12, 0.01]

(* more exact calc *)

t9[t_] = t4[t] /. Exp[x_] -> 1+x+x^2/2
t8[t_] = t2[t] /. Exp[x_] -> 1+x+x^2/2

Solve[t9[t]==t8[t], int2] /.
 {fee*min -> 0, fee*int -> 0, int*min->0, fee*int^2 -> 0,
  int^2*min -> 0, min^2 -> 0, int^2 ->0, min^2*t^2 -> 0}

ExpandAll[Solve[t9[t]==t8[t], int2]] /.
 {fee*min -> 0, fee*int -> 0, int*min->0, fee*int^2 -> 0,
  int^2*min -> 0, min^2 -> 0, int^2 ->0, min^2*t^2 -> 0}

int2 /. %[[1]]



conds =  {int -> 6/100, min -> 3/100, fee -> 2/100}

Solve[owed[t] == have[t], int2] /.
DSolve[{
 owed'[t] == int*owed[t] - min*owed[t] /. conds,
 have'[t] == int2*have[t] - min*owed[t] /. conds,
 have[0] == 1 /. conds,
 owed[0] == 1+fee /. conds
}, {owed[t], have[t]}, t]

(* use http://aa.usno.navy.mil/cgi-bin/aa_rstablew.pl data to find best fit curve for length of day *)

<<"!perl -anle 'sub BEGIN {print \"data={\"} sub END {print \"}\"} unless (/^[0-9]/) {next;} print \"{\"; for $i (0..11) {$x=substr($_,5+11*$i,10);$x=~s/\s/,/;$x=~s/\s*$//; print \"{$x},\"}; print \"},\"' /home/barrycarter/BCGIT/db/srss-60n.txt"

(* below is probably correct version for all files, but turns out to
be irrelevant south of 60N? *)

<<"!perl -anle 'sub BEGIN {print \"data={\"} sub END {print \"}\"} unless (/^[0-9]/) {next;} print \"{\"; for $i (0..11) {$x=substr($_,4+11*$i,10);$x=~s/\s/,/;$x=~s/\s*$//; print \"{$x},\"}; print \"},\"' /home/barrycarter/BCGIT/db/srss-70n.txt"

(* the data is in ugly form: hhmm, and each rows represents a date,
like the 27th, for each month; the below cleans this up nicely *)

f[x_] = Floor[x/100] + Mod[x,100]/60
d2 = Map[f,DeleteCases[Flatten[Transpose[DeleteCases[data,Null]]],Null]]
d3 = Table[d2[[i+1]]-d2[[i]],{i,1,Length[d2],2}]

(* nice, sine-like wave below *)

ListPlot[d3]

(* first three Fourier terms appear to work well *)

fitme[x_] = c0 + c1*Sin[x/366*2*Pi + c2] + c3*Sin[2*x/366*2*Pi + c4] +
 c5*Sin[3*x/366*2*Pi + c6]

(* modified below for 65N case *)

fitme[x_] = c0 + c1*Sin[x/366*2*Pi + c2] + c3*Sin[2*x/366*2*Pi + c4] +
 c5*Sin[3*x/366*2*Pi + c6] + c7*Sin[4*x/366*2*Pi + c8] + 
 c9*Sin[5*x/366*2*Pi + c10]

fitme[x_] = c0 + c1*Sin[x/366*2*Pi + c2] + c3*Sin[2*x/366*2*Pi + c4] +
 c5*Sin[3*x/366*2*Pi + c6] + c7*Sin[5*x/366*2*Pi + c8]*Sin[1/2*x/366*2*Pi+c9]


fit[x_] = fitme[x] /.
FindFit[d3, fitme[x], {c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10}, x]

fit[x_] = fitme[x] /.
FindFit[d3, fitme[x], {c0,c1,c2,c3,c4,c5,c6}, x]

(* residuals (in minutes) *)
diffs = Table[60*(d3[[i]] - fit[i]),{i,1,366}]

ListPlot[diffs,PlotRange->All,PlotJoined->True]

(*

Results:

for 35N: 

12.17695810564663 - 2.2953248962442743*Sin[1.3975767265331764 - (Pi*x)/183] - 
 0.021757064356510064*Sin[1.4830003645309824 + (2*Pi*x)/183] - 
 0.05791554634652895*Sin[2.0862521448266143 + (Pi*x)/61]

for 40N:

12.195309653916212 - 2.7657088311643028*
  Sin[1.3970291332060125 - (Pi*x)/183] - 0.026018266221687174*
  Sin[1.4457660007570647 + (2*Pi*x)/183] - 
 0.07493789567389378*Sin[2.078928604511676 + (Pi*x)/61]

for 45N:

12.21848816029144 - 3.3213738010117693*Sin[1.3975212065347047 - (Pi*x)/183] - 
 0.029619752930272168*Sin[1.4369720568764897 + (2*Pi*x)/183] - 
 0.10039096273827293*Sin[2.0864065165171435 + (Pi*x)/61]

for 50N:

12.249863387978142 - 4.004529463127261*Sin[1.3975199952244841 - (Pi*x)/183] - 
 0.032938707095312054*Sin[1.3708424645486041 + (2*Pi*x)/183] - 
 0.13710842909531928*Sin[2.09344402070527 + (Pi*x)/61]

for 55N: (diffs of over 1m, and definitely showing a "sin(5x)" pattern)

12.29535519125683 - 4.88712126398891*Sin[1.3974823984389089 - (Pi*x)/183] - 
 0.03179707785286025*Sin[1.2247093298434937 + (2*Pi*x)/183] - 
 0.20085908488999415*Sin[2.0960777979500858 + (Pi*x)/61]

for 60N: (diffs approaching 3m, strong "sin(5x)" pattern)

12.366621129326047 - 0.3323859261039487*Sin[1.0498084329064128 - (Pi*x)/61] + 
 6.126639453559547*Sin[4.539058614130759 - (Pi*x)/183] - 
 0.028173091102636834*Sin[0.5143017626631174 + (2*Pi*x)/183]

for 65N: (diffs up to 20m, "sin(5x)" pattern is strong)

12.53943533697632 + 8.227563673411336*Sin[4.538803223403626 - (Pi*x)/183] + 
 0.14114455405156695*Sin[2.20319450021785 + (2*Pi*x)/183] - 
 0.7550946690168826*Sin[2.093554971972919 + (Pi*x)/61]

12.538333951043256 + 8.230179551945618*Sin[4.538729883308269 - (Pi*x)/183] - 
 0.24546385293978604*Sin[3.8150139254154904 - (5*Pi*x)/183]*
  Sin[3.1507227641197093 + (Pi*x)/366] - 0.13662959788605702*
  Sin[5.343824436119907 + (2*Pi*x)/183] - 0.7651221272215183*
  Sin[2.09729425139858 + (Pi*x)/61]


*)



(* Use KABQ hourly data to determine trends, db/abqhourly.m (after bunzip) *)

(* -9999 = temp unknown  and drops nulls *)
data = Select[data, #[[5]] > -9999 &];

(* closer to the way we need it *)
data2 = Table[{ {x[[2]],x[[3]],x[[4]]}, {x[[1]],x[[5]]}}, {x,data}];

(* Gather by mo-da-hr *)

data3 = Gather[data2, #1[[1]] == #2[[1]] &];

(* now get da-mo-hr -> list (easy way to do this? 
http://stackoverflow.com/questions/6974544/using-mathematica-gather-collect-properly)
*)

data4 = Table[{x[[1,1]], Table[y[[2]], {y,x[[2]]}]}, {x,data3}];

f[m_] := {data3[[m,1,1]], Table[data3[[m,n,2]],{n,Length[data3[[m]]]}]}

data5 = Table[f[i],{i,1,Length[data3]}];

Fit[data5[[8,2]], {1,x}, x]

data6 = Table[{x[[1]], Fit[x[[2]], {1,t}, t]}, {x, data5}];

data7 = Table[{x[[1]], D[x[[2]],t]}, {x, data6}];

data8 = Sort[data7];

data9 = Table[x[[2]], {x,data8}]

(* daily *)
Table[Take[data9,{i*24+1,i*24+24}],{i,0,365}]
data11 = Table[Mean[Take[data9,{i*24+1,i*24+24}]],{i,0,365}]

ListPlot[data11, PlotJoined->True]

data10 = Fourier[data9]

ListPlot[data9, PlotJoined -> True]

(* normal approximation to binomial distribution *)

(* roll 100d6 and look at frequency of individual numbers *)

Plot[PDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x],{x,0,100}, 
 PlotRange->All]

Solve[CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x] == 5/6, x]

(* Out[23]= {{x -> 20.272}} *)

(* prob that at least one will exceed 20 is about 70% *)

1-CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], 20]^6

(* whats the CDF? of that *)

atleastone[x_] = 1-CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x]^6

(* CDF for highest freq? *)

Plot[1-atleastone[x],{x,0,100}]

pdfatleastone[x_] = D[CDF[NormalDistribution[100/6, Sqrt[100/6*5/6]], x]^6,x]

Plot[pdfatleastone[x],{x,0,100},PlotRange->All]

(* for
http://www.quora.com/If-I-repeatedly-roll-a-fair-k-sided-die-how-many-rolls-on-average-will-it-take-before-Ive-rolled-any-number-n-times
between 10-55 *)

quorarolls[n_] = 1-CDF[NormalDistribution[n/6, Sqrt[n/6*5/6]], 10]^6
dquorarolls[n_] = D[1-CDF[NormalDistribution[n/6, Sqrt[n/6*5/6]], 10]^6,n]

Plot[quorarolls[n],{n,10,54}]
Plot[dquorarolls[n],{n,10,54}]

Integrate[quorarolls[n],{n,10,54}]
Integrate[dquorarolls[n],{n,10,54}]

t1 = N[Table[quorarolls[n],{n,10,54}]]

Plot[PDF[BionomialDistribution[96,1/6],x],{x,0,96}]

(* unusual property of Sin[] that may be an alternative to Fourier *)

f[x_] = a+b*Sin[c*x+d]

(* result below is -c^2 *)
f'''[x]/f'[x]

(* how about this... *)

Log[f'[x]]
D[Log[f'[x]],x]
Log[D[Log[f'[x]],x]]
D[Log[D[Log[f'[x]],x]],x]
Log[D[Log[D[Log[f'[x]],x]],x]]
D[Log[D[Log[D[Log[f'[x]],x]],x]],x]

(* above is fun, but useless *)

(* slightly more complex *)

f[x_] = a1 +b1*Sin[c1*x+d1] +b2*Sin[c2*x+d2]

(* with x data of jupiter *)

<<"!bzcat /home/barrycarter/20110916/final-pos-500-0-199.txt.bz2"; 

p0 = planet199;
p1 = p0[[1;;Length[p0];;10]];
Clear[p0];
Clear[planet199];
px = Table[{x[[2]]-2455562.500000000,x[[3]]},{x,p1}];
g = Interpolation[px, InterpolationOrder->3]
Plot[g'''[x]/g'[x],{x,0,2922}]
Integrate[g'''[x]/g'[x],{x,0,2922}]/2922.

(* anti-Fourier values? *)

(* known perpindicular *)
Integrate[Sin[2*x]*Sin[3*x],{x,0,2*Pi}]

Integrate[Sin[58/10*x]*Sin[7*x],{x,0,2*Pi}]

h[n_] = Integrate[Sin[58/10*x]*Sin[n*x],{x,0,2*Pi}]

Solve[%==0, n]

Plot[h[n],{n,3,8}]


(* metaf2xml's first formula for humidity, reversing to get dewpoint *)

humid[t_, d_] = 10^(7.5 * (d / (d + 237.7) - t / (t + 237.7)))
humidf[t_, d_] = humid[(t-32)/1.8, (d-32)/1.8]

dewpoint[t_, h_] = d /. Solve[humidf[t,d]==h, d][[1]]

(* t in Celsius *)
satpressure[t_] = 6.1121*Exp[(18.678-t/234.5)*(t/(257.14+t))]

humid[t_, d_] = satpressure[d]/satpressure[t]

Solve[humid[t,d]==h, d]



(* the two body problem? *)

DSolve[{
 d2[t] == (x1[t]-x0[t])^2 + (y1[t]-y0[t])^2 + (z1[t]-z0[t])^2,
 D[x0[t], t,t] == (x1[t]-x0[t])/d2[t],
 D[y0[t], t,t] == (y1[t]-y0[t])/d2[t],
 D[z0[t], t,t] == (z1[t]-z0[t])/d2[t],
 D[x1[t], t,t] == -(x1[t]-x0[t])/d2[t],
 D[y1[t], t,t] == -(y1[t]-y0[t])/d2[t],
 D[z1[t], t,t] == -(z1[t]-z0[t])/d2[t]
}, {x0,y0,z0,x1,y1,z1,d2}, t
]



n = 200;
data = N[Table[Sin[3.17*2*Pi*x/200], {x, 1, n}]];
welch = 1 - (2 (Range[n] - (n - 1)/2)/(n + 1))^2;
fData = Append[Abs[Fourier[welch*data]]^2 / (Plus @@ (welch^2)), 0];
ListPlot[fData, PlotRange->All]
fData = (fData + Reverse[fData])/2;
fData = fData / (Plus @@ fData);
Log[fData]
f = Interpolation[Log[fData], InterpolationOrder -> 3];
Plot[f[x],{x,1,5}]

t1 = N[Table[Sin[3/2*2*Pi*x/10000], {x,1,10000}]];
t2 = N[Table[Sin[20*2*Pi*x/10000], {x,1,10000}]];
t3 = N[t1*t2]
t4 = N[Table[Sin[2*Pi*x/200], {x,1,200}]];
t5 = N[Table[Sin[20*2*Pi*x/10000], {x,1,9750}]];
t4 = N[Table[Sin[3.17*2*Pi*x/200], {x,1,200}]];

t4m = t4[[1;;Length[t4];;10]]
i1 = Interpolation[t4m, InterpolationOrder->16]

Plot[i1[x],{x,1,20}]

Table[i1[1+(x-1)/10] - t4[[x]], {x,1,200}]

diffs = Table[t4[[i]] - t4[[i-1]], {i,2,Length[t4]}]
diff[t_] := Table[t[[i]] - t[[i-1]], {i,2,Length[t]}]

t42 = diff[diff[t4]]

NonlinearModelFit[t4, a*Cos[b*x-c], {{a, 0.983639} ,{b, -0.0992743},
 {c, -1.49867}}, x]

superfourier[t4]

ListPlot[t4/Max[Abs[t4]]]
ListPlot[ArcCos[t4/Max[Abs[t4]]]]

Integrate[Sin[x], {x,0,2*Pi*3.17}]
Integrate[Cos[x], {x,0,2*Pi*3.17}]
Integrate[Cos[1.49867-x], {x,0,2*Pi*3.17}]

superfour[t2,1][7]

t3 = N[Table[Sin[3/2*2*Pi*x/10000]  * Sin[20*2*Pi*x/10000], {x,1,10000}]];

t3 = N[Table[Sin[n*2*Pi*x/10000]  * Sin[m*2*Pi*x/10000], {x,1,10000}]];
t3 = Table[Sin[n*2*Pi*x/10000]  * Sin[m*2*Pi*x/10000], {x,1,10000}];
t3 = Table[Sin[n*2*Pi*x/10000]  * Sin[m*2*Pi*x/10000], {x,1,100}];

t4 = Fourier[t3]

ListPlot[Abs[t4], PlotRange->All]

Select[t4, # != 0 &]


Simplify[Sin[n*x]*Sin[m*x], {Element[x,Reals]}]
TrigFactor[Sin[n*x]*Sin[m*x]]
TrigReduce[Sin[n*x]*Sin[m*x]]
Log[Sin[n*x]*Sin[m*x]]



(* from http://hpiers.obspm.fr/eop-pc/models/constants.html *)
ecliptic = ArcSin[0.397776995]
mecliptic = {{1,0,0}, {0, Cos[ecliptic], -Sin[ecliptic]},
 {0, Sin[ecliptic], Cos[ecliptic]}}

(* positions at 2455833.933333333 *)

earth = {1.485770387408892*10^+08, 1.494799659360260*10^+07,
3.747770517099129*10^+02}

jupiter = {6.257010398453077*10^+08, 3.974473247851866*10^+08,
-1.566407515423084*10^+07}

vec1 = jupiter - earth
vec = mecliptic . (vec1)

ArcSin[vec[[3]]/Norm[vec]]

(* -1.46448 in degrees *)


(* figure out 1900 GMT today and next Friday *)

DateList[{"next Friday", {"DayName"}}]


(* an ellipse w/ semimajor axis a, periapsis qr, apoapsis ad, NE quadrant *)

y[x_, a_, qr_] = y /.
 Solve[{Sqrt[(x+a-qr)^2 + y^2] + 
        Sqrt[(x-a+qr)^2 + y^2] == 2*a}, {y}][[2,1]]

Plot[y[x,3,2],{x,-5,5}]

Graphics[Plot[y[x,3,2],{x,-5,5}], Text["hello",{1,3}]]

Plot[Text["Hello",{1,0}], {x,-1,1}]

(* tti = thing to integrate *)

tti[x_, a_, qr_, theta_] = Min[(x-(a-qr))*Tan[theta], y[x, a, qr]]

Plot[tti[x,3,2, 60 Degree],{x,1,6}]

Plot[{y[x,3,2], tti[x,3,2, 60 Degree]},{x,-5,5}]

area[a_, qr_, theta_] = Integrate[tti[x,a,qr,theta], {x,a-qr,a}, 
 Assumptions -> {0 < theta < Pi/2, a>0, qr>0, Member[theta, Reals], 
 Member[a, Reals], Member[qr, Reals]}]

Integrate[tti[x,1,5,45 Degree], {x,1,1+5}]

Integrate[tti[x,1,5,theta], {x,1,1+5}]

(* mathematica does above, but not below *)

Integrate[tti[x,1,5,theta], {x,a,a+5}]

Integrate[tti[x,a,5,theta], {x,a,a+5}]

Integrate[Min[y[x,a,qr], (x-a)*m], {x,a,a+qr}]

Integrate[Min[y[x,a,qr], (x-a)*2], {x,a,a+qr}]

Integrate[Min[y[x,a,3], (x-a)*2], {x,a,a+3}]

Integrate[y[x,a,qr], {x,x1,x2}]

sliver[a_, qr_, x1_] = 
Integrate[y[x,a,qr], {x,x1,a}, Assumptions -> {a>0, qr>0, x1>0, a > x1}]

meetpt[a_, qr_, m_] = x /. Solve[y[x,a,qr] == m*(x-(a-qr)), x][[2]]

sliver[a, qr, meetpt[a,qr,m]] // CForm
sliver[a, qr, meetpt[a,qr,m]] // SyntaxForm
sliver[a, qr, meetpt[a,qr,m]] // TreeForm

tti[x, 3.870991416593402/10, 3.075015900415988/10, theta]

sliver[1,qr,m*qr]


(* area at angle theta from focus [not center] *)

tti[x_, theta_] = Min[Tan[theta]*(x-a), y[x]]
tti[x_, m_] = Min[m*(x-a), y[x]]
Integrate[tti[x,theta], {x,a,a+qr}]

(* mathematica won't do above, so lets figure out what breaks it *)

Integrate[Min[x-a,y[x]],{x,a,a+qr}] /. a->4






(* ellipses *)

f[x_] = y/. Solve[Sqrt[(x+1)^2 + y^2] + Sqrt[(x-1)^2 + y^2] == 5, y][[2,1]]
Plot[f[x], {x,-6,6}, AspectRatio -> Fixed, AxesOrigin -> {0,0}]
Integrate[f[x], {x,0,2}]
g[x_, m_] = Min[m*(x-1), f[x]]
Plot[g[x,2], {x,1,5/2}, AspectRatio -> Fixed, AxesOrigin -> {0,0}]
Integrate[g[x,2], {x,1,5/2}]
h[m_] = Simplify[Integrate[g[x,m], {x,1,5/2}], {m>0}]
Solve[h[m] == x, m]

Integrate[g[x,ArcTan[theta]], {x,1,5/2}]



(* Eternal Lands *)

(* how much stuff do I have right now? ii = in inventory *)
coalii = 101;
feii = 150;
ioii = 1313;
gpii = 1225;

(* how much does stuff cost from bots? bs = botsell *)

coalbs = 0;
febs = 4.95;
iobs = 3.20;

(* how to buy stuff to maximize number of steel bars? tb = to buy *)

(* tb < 0 non-sensical since I can't sell at botsell prices *)

Solve[{
 (ioii+iotb)/8 == (feii+fetb)/3 == (coalii+coaltb)/5,
 Max[iotb,0]*iobs + Max[fetb,0]*febs + Max[coaltb,0]*coalbs == gpii
}, {iotb,fetb,coaltb}]

(* tennis game at deuce, p change of getting point, q=1-p *)

Simplify[Solve[x == p^2 + 2*p*q*x, x] /. q -> 1-p]


(* box options *)

Integrate[
PDF[NormalDistribution[0,v1]][x]*(1-CDF[NormalDistribution[0,v2]][a-x]),
{x,-Infinity,a}
]

Integrate[
PDF[NormalDistribution[0,v1]][x]*PDF[NormalDistribution[0,v2]][y],
{x,-Infinity,a}, {y,a-x,Infinity}, Assumptions -> {v1>0, v2>0}
]

Plot[PDF[HalfNormalDistribution[1]][x], {x,-10,10}]

testmax[x_] = If[x>0, PDF[HalfNormalDistribution[1]][x], 0]

Plot[testmax[x],{x,-5,5}]

test2[x_] = Integrate[
 PDF[NormalDistribution[0,1]][y] * testmax[x-y], {y,-Infinity,x}]

Plot[test2[x],{x,-5,5}]

testmax[x_] = If[x>0, PDF[HalfNormalDistribution[1/10]][x], 0]

maxdist[x_, v_] = If[x>0, PDF[HalfNormalDistribution[v]][x], 0]

maxdistv[x_, v1_, v2_] = Integrate[
 PDF[NormalDistribution[0,v1]][y] * maxdist[x-y, v2], {y,-Infinity,x},
 Assumptions -> {v1>0, v2>0}]

maxdistv[x,1,2]

val1[a_, v1_, v2_] := 
NIntegrate[
PDF[NormalDistribution[0,v1]][x] * (1-CDF[HalfNormalDistribution[v2]][a-x]),
{x,-Infinity,a}]

Interpolation[{{a,v1,v2}, val1[a,v1,v2]}

Table[{{a,v1,v2},val1[a,v1,v2]}, {a,1}, {v1,0.1,0.2,.01}, {v2,0.1,0.2,.01}]

val1[1,.1,.1]

FunctionInterpolation[val1[a,v1,v2], {a,0,1}, {v1,0,1}, {v2,0,1}]


(* combining two barrier options?

stays above: upper+lower long wins
stays below: upper+lower short wins
inbetween: lower: long wins; upper: short wins

suppose upper long pays 300 w/ 100 bet, profit is:
suppose lower long pays 200 w/ 100 bet, profit is:

upper is 1.5
lower is 1.25

*)

profit[p_] = If[p>1.5, 300-100, -100] - If[p>1.25, 200-100, -100]

Plot[profit[p], {p,1,2}]



Exit[]

tox[ra_, dec_] = (Pi+dec*Degree)*Cos[ra*Degree]
toy[ra_, dec_] = (Pi+dec*Degree)*Sin[ra*Degree]

dec1 = AstronomicalData["Moon", "Declination"]
ra1 = AstronomicalData["Moon", "RightAscension"]*15

tox[ra1,dec1]
toy[ra1,dec1]

Table[AstronomicalData["Moon", {"RightAscension", DateList[x]}], 
 {x, AbsoluteTime[{2011,5,25,19}], AbsoluteTime[{2011,5,26,10}]}]



Exit[]

tab = Table[a[i], {i,1,100}]

f = Interpolation[tab]

f1[x_] := f[42+x] /. {a[42] -> 0, a[43] ->0, a[44] -> 0, a[41] -> 1}
t1 = Table[{x,f1[x]}, {x,.01,.99,.01}]
FindFit[t1, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

f2[x_] := f[42+x] /. {a[41] -> 0, a[43] ->0, a[44] -> 0, a[42] -> 1}
t2 = Table[{x,f2[x]}, {x,.01,.99,.01}]
FindFit[t2, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

f3[x_] := f[42+x] /. {a[41] -> 0, a[42] ->0, a[44] -> 0, a[43] -> 1}
t3 = Table[{x,f3[x]}, {x,.01,.99,.01}]
FindFit[t3, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

f4[x_] := f[42+x] /. {a[41] -> 0, a[42] ->0, a[43] -> 0, a[44] -> 1}
t4 = Table[{x,f4[x]}, {x,.01,.99,.01}]
FindFit[t4, c0 + c1*x + c2*x^2 + c3*x^3, {c0,c1,c2,c3}, x]
Factor[Chop[c0 + c1*x + c2*x^2 + c3*x^3 /. %]]

Plot[f1[x]+f2[x]+f3[x]+f4[x], {x,0,1}]

(* below is identically one as expected *)
Table[f1[x]+f2[x]+f3[x]+f4[x], {x,0,1,.01}]

h1[x_] = (x-2)*(x-1)*x/-6
h2[x_] = (x-2)*(x-1)*(x+1)/2
h3[x_] = x*(x+1)*(x-2)/-2
h4[x_] = (x-1)*x*(x+1)/6

Plot[{h1[x],h2[x],h3[x],h4[x]}, {x,0,1}]

Plot[{h1[x],f1[x]}, {x,0,1}]
Plot[{h2[x],f2[x]}, {x,0,1}]
Plot[{h3[x],f3[x]}, {x,0,1}]
Plot[{h4[x],f4[x]}, {x,0,1}]

(* results:

(x-2)*(x-1)*x/-6 <- coeff of 41

(x-2)*(x-1)*(x+1)/2 <- coeff of 42

x*(x+1)*(x-2)/-2 <- coeff of 43

(x-1)*x*(x+1)/6 <- coeff of 44

*)

Plot[{f[42+x] /. {a[42] -> 0, a[43] ->0, a[44] -> 0, a[41] -> 1}},
 {x,0,1}]

Plot[{f[42+x] /. {a[41] -> 0, a[43] ->0, a[44] -> 0, a[42] -> 1}},
 {x,0,1}]

Plot[{f[42+x] /. {a[42] -> 0, a[41] ->0, a[44] -> 0, a[43] -> 1}},
 {x,0,1}]

Plot[{f[42+x] /. {a[42] -> 0, a[43] ->0, a[41] -> 0, a[44] -> 1}},
 {x,0,1}]




Exit[]

altintfuncalc[f_, t_] := Module[
 {xvals, yvals, xint, tisin, tpos, m0, m1, p0, p1},

 (* figure out x values *)
 xvals = Flatten[f[[3]]];

 (* and corresponding y values *)
 yvals = Flatten[f[[4,3]]];

 (* HACK: for some reason, t1 is bizarre *)
// yvals = Flatten[f[[4]]];


 (* and size of each x interval; there are many other ways to do this *)
 (* <h>almost all of which are better than this?</h> *)
 xint = (xvals[[-1]]-xvals[[1]])/(Length[xvals]-1);

 (* for efficiency, all vars above this point should be cached *)

 (* which interval is t in?; interval i = x[[i]],x[[i+1]] *)
 tisin = Min[Max[Ceiling[(t-xvals[[1]])/xint],1],Length[xvals]-1];

Print["TISIN ",tisin];
Print["XVALS ",xvals];
Print["YVALS ",yvals];

 (* and the y values for this interval, using Hermite convention *)
 p0 = yvals[[tisin]];
 p1 = yvals[[tisin+1]];

 (* what is t's position in this interval? *)
 tpos = (t-xvals[[tisin]])/xint;

 (* what are the slopes for the intervals immediately before/after this one? *)
 (* we are assuming interval length of 1, so we do NOT divide by int *)
 m0 = p0-yvals[[tisin-1]];
 m1 = yvals[[tisin+2]]-p1;

 (* return the Hermite approximation *)
 (* <h>Whoever wrote the wp article was thinking of w00t</h> *)
 h00[tpos]*p0 + h10[tpos]*m0 + h01[tpos]*p1 + h11[tpos]*m1
]

t1 = Interpolation[Table[x*x,{x,1,10}]]

altintfuncalc[t1, 9.5]


Exit[]

(* if we map ra/dec as theta, r (r= 90+dec), do we have something? 
(it's at least only 2D *)

dec[t_] = 23*Sin[t*2*Pi/365]
ra[t_] = t/365*24/24*2*Pi

Plot[{ra[t],dec[t]},{t,0,365}]

x[t_] = (90+dec[t])*Sin[ra[t]]
y[t_] = (90+dec[t])*Cos[ra[t]]

Plot[x[t],{t,0,365}]
Plot[y[t],{t,0,365}]

Exit[]

(* if we have lots of data, can we "compress" it in an odd way? *)

(* trying to do 10 years at a time slow things down a bit, so maybe 1 year *)

data = Take[data, 10000];

(* start with dec *)

moondec = Table[{i[[1]], i[[3]]}, {i,data}];

datareduce[data_, n_] := Module[{halfdata, inthalfdata, tabhalfdata, origdata},
 halfdata = Take[data, {1,Length[data],2^n}];
Print["halfdata complete"];
 inthalfdata = Interpolation[halfdata];
Print["inthalfdata complete"];
 tabhalfdata = Table[inthalfdata[data[[i,1]]], {i, 1, Length[data]}];
Print["tabhalfdata complete"];
 Return[tabhalfdata];
]

t1 = datareduce[moondec, 1];
t2 = Table[moondec[[i,2]], {i, 1, Length[data]}];
t3 = t1-t2;

(* vaguely bad that I'm using data as a parameter, but won't cause
Mathematica problem *)

(* take each 2^nth piece of data *)
halfdata[data_, n_] := Take[data, {1,Length[data],2^n}]

(* interpolate it *)
inthalfdata[data_, n_] := Interpolation[halfdata[data,n]]

(* new data *)
tabhalfdata[data_, n_] := 
 Table[inthalfdata[data,n][data[[i,1]]], {i, 1, Length[data]}]

(* and compare *)
maxdiff[data_, n_] := Max[tabhalfdata[data,n]];

moondechd = halfdata[moondec,1];





mindata = Table[{i, data[[i]]}, {i,1,Length[data],50}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],500}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],5000}]

amindata = Interpolation[mindata]
amindata = Interpolation[mindata, InterpolationOrder->1]
amindata = Interpolation[mindata, InterpolationOrder->2]
amindata = Interpolation[mindata, InterpolationOrder->0]
amindata = Interpolation[mindata, InterpolationOrder->5]
amindata = Interpolation[mindata, InterpolationOrder->17]

atab = Table[amindata[x], {x,1,Length[data]}]

ListPlot[data-atab]

Max[Abs[data-atab]]



Exit[]

mod[x_] := Module[{coeff,a},
 coeff= {1,2,3};
 Function[y, Evaluate[x+coeff[[1]]+y]]
]

mod[7]


Exit[]

(* table of inverse normal curve for NADEX vols *)

inv[x_] = y /. Solve[CDF[NormalDistribution[0,1]][y]==x,y][[1]]

Flatten[Table[{N[x,4],N[inv[x],10]},{x,0,1,25/10000}]
 ] >> /home/barrycarter/BCGIT/data/inv-norm-as-list.txt

Exit[]

(* how much worse is linear interpolation for moonpos? *)

t = << /home/barrycarter/BCGIT/sample-data/manytables.txt

Flatten[t[[1,3,3,3]]]

(* the xyz vals from Hermite approx, for 2011 *)

hxval[r_] := t[[1,1,3]][r]
hyval[r_] := t[[1,2,3]][r]
hzval[r_] := t[[1,3,3]][r]

hdec[r_] := ArcSin[hzval[r]/Sqrt[hxval[r]^2+hyval[r]^2+hzval[r]^2]]/Degree

Plot[hdec[r],{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

(* and the domain, range for the x values of the moon *)

Flatten[t[[1,1,3,3]]]
Flatten[t[[1,1,3,4,3]]]

xm1 = Table[{t[[1,1,3,3,1,i]], t[[1,1,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
ym1 = Table[{t[[1,1,3,3,1,i]], t[[1,2,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
zm1 = Table[{t[[1,1,3,3,1,i]], t[[1,3,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]

flatx = Interpolation[xm1, InterpolationOrder -> 1]
flaty = Interpolation[ym1, InterpolationOrder -> 1]
flatz = Interpolation[zm1, InterpolationOrder -> 1]

flatdec[r_] := ArcSin[flatz[r]/Sqrt[flatx[r]^2+flaty[r]^2+flatz[r]^2]]/Degree

Plot[{flatx[r] - hxval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flaty[r] - hyval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatz[r] - hzval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

Plot[{flatdec[r],hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatdec[r]-hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]},
 PlotRange->All]

(* trivial difference, so could've just used linear *)

(* Hermite broken, fixing? *)

l={3.391804676434298,3.183960097542073,2.9043571833527966,2.5667537942969005}

l1=Interpolation[l]
d1[x_] = D[l1[x],x]
d2 = D[d1]

Plot[{l1[x],d1[x]}, {x,1,4}]
Plot[{d1[x]}, {x,1,2}]

Plot[l1[x] - l1[Floor[x]]*h00[x-Floor[x]] -
     h01[x-Floor[x]]*l1[Ceiling[x]]
, {x,1,2}]

Plot[l1[x],{x,1,4}]

Plot[D[l1][y], {y,1,2}]

altintfuncalc[l1, 2.5]

(* confirmed that my implementation of hermite above is broken *)

Plot[{h00[t], h01[t], h10[t], h11[t]}, {t,0,1}]

(* list = {1,4,9,16,25,36} *)

list = Table[x*x*x,{x,1,6}]

func = Interpolation[list]

Plot[func[x], {x,1,6}]

Plot[func[x]-x*x*x, {x,1,6}]

test1[x_] := func[x] - h00[x-Floor[x]]*list[[Floor[x]]] - 
 h01[x-Floor[x]]*list[[Floor[x+1]]]

Plot[test1[x],{x,1,6}]

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == 1.54688,
 h10[.75]*m0 + h11[.75]*m1 == -5.48438
}, {m0,m1}
]

(slopes 27 and 48, NOT 28 and 49 as expected)

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == 0.421875,
 h10[.75]*m0 + h11[.75]*m1 == -3.23438
}, {m0,m1}
]

(slopes 12 and 27, vs 13 and 28 as expected)

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[2.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[2.75]
}, {m0,m1}
]

slopes 3 and 12; expected 1 and 13

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[4.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[4.75]
}, {m0,m1}
]

slopes 48 and 75 vs 49 and 76

Solve[{
 h10[.125]*m0 + h11[.125]*m1 == test1[4.125],
 h10[.375]*m0 + h11[.375]*m1 == test1[4.375]
}, {m0,m1}
]

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[2.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[2.75]
}, {m0,m1}
]

slopes 5 and 30.5 vs 2.5, 28 my calc [when first number is 22]

making it 200

my slopes: -86.5, 28

theirs: -54.3333 and 60.1667

32.167 higher in both cases

so 22 -> 2.5, 200 -> 32.167

67 higher in another case

Table[list[[i]]-list[[j]], {i,1,Length[list]}, {j,1,Length[list]}]

between 8,27 what does my way give you?

h00[.75]*8 + h01[.75]*27 + h10[.75]*13 + h11[.75]*28

(this is for 2.75)

h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28

yields: 8 + 13*t + 3*t^2 + 3*t^3

h00[t-2]*8 + h01[t-2]*27 + h10[t-2]*13 + h11[t-2]*28

-30 + 37*t - 15*t^2 + 3*t^3

where as using their #s

h00[t]*8 + h01[t]*27 + h10[t]*12 + h11[t]*27

yields (2+t)^3


h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28 - (t+2)^3

t*(1 - 3*t + 2*t^2) <- hermite polynomial?

left[t_] = t*(1 - 3*t + 2*t^2)

Simplify[left[t] - h00[t]]
Simplify[left[t] - h01[t]]
Simplify[left[t] - h10[t]]
Simplify[left[t] - h11[t]]

h00 is 1 - 3*t^2 + 2*t^3

while leftover is

t - 3*t^2 + 2*t^3

(interesting)

Solve[h00[t]*8 + h01[t]*27 + h10[t]*m0 + h11[t]*m1 - (t+2)^3 == 0, {m0,m1}]

(3^3-1.5^3)/2

Solve[3^3-x^3 == 24,x]

Interpolation[{8,27,64,125}]

Plot[5*h10[t] + 7*h11[t], {t,0,1}]


myway[t_] = h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28

hmmm, why doesn't 28 show up in derv

myway[t_] = h00[t]*27 + h01[t]*8 + h10[t]*28 + h11[t]*13

test1[t_] = h10[t]*28 + h11[t]*13

Plot[D[test1][t], {t,0,1}]

28*(1 - t)^2*t + 13*(-1 + t)*t^2 <- derv of my way

Plot[27*(1 - t)^2*t + 12*(-1 + t)*t^2, {t,0,1}]

Plot[(27*(1 - t)^2*t + 12*(-1 + t)*t^2)-D[test1][t], {t,0,1}]

derv1[t_] = D[test1[t],t]

derv2[t_] = D[derv1[t],t]

dtheir[t_] = D[27*(1 - t)^2*t + 12*(-1 + t)*t^2, t]
d2their[t_] = D[dtheir[t],t]

(* wow, mathematica lets you do general interpolation! *)

f = Interpolation[{a,b,c,d}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

f = Interpolation[{a,b,c,d,e,f}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[3+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3+3/4]
}, {m0,m1}
]




Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[3+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3+3/4]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {8, y1},
 {9, y2},
 {10, y3},
 {11, y4},
 {12, y5}
}]


Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[9+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[9+3/4]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {7.01, y1},
 {7.02, y2},
 {7.03, y3},
 {7.04, y4},
 {7.05, y5}
}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[7.02+1/400],
 h10[3/4]*m0 + h11[3/4]*m1 == f[7.02+3/400]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {8, y1},
 {15, y2},
 {22, y3},
 {115, y4},
 {116, y5}
}]

cubic[x_] = (Random[]-.5) + (Random[]-.5)*x + (Random[]-.5)*x*x + 
 (Random[]-.5)*x*x*x

Plot[cubic[x],{x,0,1}]

(* my own spline? (quadratic?) *)

(*

suppose (a5,a6) is the interval of interest

(a5+a6)/2 = constant

(a6-a5)/len = first derv

((a6-a5)/len - (a5-a4)/len + ((a6-a5)/len - (a7-a6)/len))/2

(1,3,3,1)/2

*)

Solve[{a==a1, c/2*1/2*1/2 + b + a == a2}, {a,b}]

Solve[{c/2*1/2*1/2 - b/2 + a == a1,
       c/2*1/2*1/2 + b/2 + a == a2
}, {a,b}]

Table[a[i], {i,1,20}]

(* first differences *)
ad1[i_, f_] = f[i]-f[i-1]

(* second diffs *)
ad2[i_, f_] = ad1[i,f] - ad1[i-1,f]

(* third diffs *)
ad3[i_, f_] = ad2[i,f] - ad2[i-1,f]

Table[Sin[i/20], {i,0,100}]
Table[ad1[i, Sin[#/20] &], {i,0,100}]
Table[ad2[i, Sin[#/20] &], {i,0,100}]
Table[ad3[i, Sin[#/20] &], {i,0,100}]

Table[Sin[i/20], {i,0,100}]

bd1[i_, f_] = (f[i+1] - f[i-1])/2
bd2[i_, f_] = (bd1[i+1, f] - bd1[i-1, f])/2
bd3[i_, f_] = (bd2[i+1, f] - bd2[i-1, f])/2

f'''[x] == c3
f''[x] == c3*x + c2 
 
slope[i_] = a[i+1] - a[i]

slope2[i_] = (slope[i+1] - slope[i-1])/2

slope3[i_] = (slope2[i+1] - slope2[i-1])/2

consider [1, 8, 27, 64, 125, 216]

and the interval 27,64 (the 2.5th interval in Perl, i=2 above)

slope = 37

slope2 = 21

slope3 = (-1 + 8 + 2*27 - 2*64 - 125 + 216)/4 = 6

rebuilding

6x + C <- second derv

6x + 21 <- second derv

3*x^2 + 21 x + 37 <- first der

f[x_] = x^3 + 21/2*x*x + 37*x + 91/2

Plot[f[x] - (x+3.5)^3, {x,-.5,.5}]

bad... instead, interval around each point

consider [1, 8, 27, 64, 125, 216]

and 4^3==64

slope[i_] = (f[i+1] - f[i-1])/2

slope2[i_] = (slope[i+1]-slope[i-1])/2

slope3[i_] = (slope2[i+1]-slope2[i-1])/2

so for 64

slope3 = (-1 + 3*27 - 3*125 + 343)/8

slope3 is 6

slope2 is (8 - 2*64 + 216)/4

slope2 is 24

slope1 is 49

constant is 64

g[x_] = 64 + 49*x + 12*x*x + x*x*x

Plot[g[x],{x,-.5,.5}]

Plot[g[x]-(4+x)^3,{x,-.5,.5}]

Table[g[x], {x,-.5,.5,.1}]

now the interval for 27

slope3 = (0 + 3*8 - 3*64 + 216)/8 == 6

slope2 = (1 - 2*27 + 125)/4 == 18

slope = 28

constant = 27

h[x_] = 27 + 28*x + 9*x*x + x*x*x

Plot[h[x],{x,-.5,.5}]

DSolve[{
 f''[x][-1/2] == a,
 f'[x][-1/2] == b,
 f[-1/2] == c,
 f''''[x] == 0,
 f[0] ==d},
f, {a,b,c,d}]

j[x_] = a3*x^3 + a2*x^2 + a1*x + a0

Solve[{
 j''[-1/2] == c2,
 j'[-1/2] == c1,
 j[-1/2] == c0,
 j[0] == c3
}, {a0,a1,a2,a3}]

consider {27,64,125}

constantleft = 91/2
constantright = 189/2

constant average ai, ai-1 and ai+1, ai

slope: left: (a[i]-a[i-2])/2 left (a[i+1] - a[i+1])/2 right

Solve[{
 j[-1/2] == c0,
 j[0] == c1,
 j[1/2] == c2,
 j'[-1/2] == c3,
 j'[1/2] == c4
}, {a0,a1,a2,a3}]

Solve[{
 j[0] == c1,
 j'[-1/2] == c4
 j'[1/2] == c2
}, {a0,a1,a2,a3}]

Solve[{
 j[0] == c0,
 j[-1] == c1,
 j[1] == c2
}, {a0,a1,a2,a3}]

j[x_] = a4*x^4 + a3*x^3 + a2*x^2 + a1*x + a0

Solve[{
 j[-1/2] == c0,
 j[0] == c1,
 j[1/2] == c2,
 j'[-1/2] == c3,
 j'[1/2] == c4
}, {a0,a1,a2,a3,a4}]

for [1,8,27,64,125,216], the 27 interval


Solve[{
 j[-1/2] == (8+27)/2,
 j[0] == 27,
 j[1/2] == (27+64)/2,
 j'[-1/2] == 27-8,
 j'[1/2] == 64-27
}, {a0,a1,a2,a3,a4}]

test1[x_] = j[x] /. %[[1]]

Plot[test1[x] - (x+3)^3,{x,-.5,.5}]

Plot[test1[x],{x,-.5,.5}]

Solve[{
 j[-1/2] == (27+64)/2,
 j[0] == 64,
 j[1/2] == (64+125)/2,
 j'[-1/2] == 64-27,
 j'[1/2] == 125-64
}, {a0,a1,a2,a3,a4}]

test2[x_] = j[x] /. %[[1]]

Plot[test2[x],{x,-.5,.5}]

Plot[If[x>3.5, test2[x-4], test1[x-3]] - x^3, {x,2.5,4.5}]

j[x_] = a4*x^4 + a3*x^3 + a2*x^2 + a1*x + a0

j[x_] = a3*x^3 + a2*x^2 + a1*x + a0

Solve[{
 j[-1/2] == (f[-1]+f[0])/2,
 j[0] == f[0],
 j[1/2] == (f[0]+f[1])/2,
 j'[-1/2] == f[0]-f[-1],
 j'[1/2] == f[1]-f[0]
}, {a0,a1,a2,a3,a4}]

(* how about 2nd derv matching? *)

Solve[{
 j''[-1/2] == (f[1]-f[0]) - (f[-1]-f[-2])
 j[0] == f[0],
 j''[1/2] == (f[2]-f[1]) - (f[0]-f[-1])
}, {a0,a1,a2,a3}]

test2[x_] = j[x] /. %[[1]]

Solve[{
 j''[-1/2] == (f[i+1]-f[i]) - (f[i-1]-f[i-2])
 j[0] == f[i],
 j''[1/2] == (f[i+2]-f[i+1]) - (f[i]-f[i-1])
}, {a0,a1,a2,a3}]

test4[x_,i_] = j[x] /. %[[1]]

D[test4[x,i],x] /. x -> -1/2

D[test4[x,i-1],x] /. x -> 1/2

Solve[(D[test4[x,i],x] /. x -> -1/2) == (D[test4[x,i-1],x] /. x -> 1/2), a1]

pre[x_, i_] = a3*x^3 + a2*x^2 + a1*x + f[i-1]
me[x_, i_] = b3*x^3 + b2*x^2 + b1*x + f[i]
post[x_, i_] = c3*x^3 + c2*x^2 + c1*x + f[i+1]

D[pre[x,i],x,x] /. x -> 1/2
D[me[x,i],x,x] /. x -> -1/2

D[pre[x,i],x] /. x -> 1/2
D[me[x,i],x] /. x -> -1/2



Solve[{
 2*a2 + 3*a3 == 2*b2 - 3*b3,
 a1 + a2 + 3/4*a3 == b1 - b2 + 3/4*b3,
 a1/2 + a2/4 + a3/8 + f[i-1] == -b1/2 + b2/4 - b3/8 + f[i],
 2*b2 + 3*b3 == 2*c2 - 3*c3,
 b1 + b2 + 3/4*b3 == c1 - c2 + 3/4*c3,
 b1/2 + b2/4 + b3/8 + f[i] == -c1/2 + c2/4 - c3/8 + f[i+1]
}, {a1,a2,a3,b1,b2,b3,c1,c2,c3}]


Solve[{
 a1 + a2 == b1 - b2,
 a1/2 + a2/4 + f[i-1] == -b1/2 + b2/4 + f[i],
 b1 + b2 == c1 - c2,
 b1/2 + b2/4 + f[i] == -c1/2 + c2/4 + f[i+1]
}, {a1,a2,a3,b1,b2,b3,c1,c2,c3}]


Solve[{
 2*a2 + 3*a3 == 2*b2 - 3*b3,
 a1 + a2 + 3/4*a3 == b1 - b2 + 3/4*b3,
 a1/2 + a2/4 + a3/8 + f[i-1] == -b1/2 + b2/4 - b3/8 + f[i],
 2*b2 + 3*b3 == 2*c2 - 3*c3,
 b1 + b2 + 3/4*b3 == c1 - c2 + 3/4*c3,
 b1/2 + b2/4 + b3/8 + f[i] == -c1/2 + c2/4 - c3/8 + f[i+1]
}, {b1,b2,b3}]

Solve[{

-5 b1 + 4 b2 - 3 b3 - 6 (f[i-1] - f[i]) ==
97 c1 - 88 c2 + 72 c3 - 6 (f[-1 + i] - 18 f[i] + 17 f[1 + i]),

12 b1 - 11 b2 + 9 b3 + 12 (f[i-1] - f[i]) ==
-264 c1 + 241 c2 - 198 c3 + 12 (f[-1 + i] - 24 f[i] + 23 f[1 + i]),

-8 b1 + 8 b2 - 7 b3 - 8 (f[i-1] - f[i]) ==
192 c1 - 176 c2 + 145 c3 - 8 (f[-1 + i] - 26 f[i] + 25 f[1 + i]),

a1 == -5 b1 + 4 b2 - 3 b3 - 6 (f[i-1] - f[i]),

a2 == 12 b1 - 11 b2 + 9 b3 + 12 (f[i-1] - f[i]),

a3 == -8 b1 + 8 b2 - 7 b3 - 8 (f[i-1] - f[i])

}, {a1,a2,a3,b1,b2,b3,c1,c2,c3}]

