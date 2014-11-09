(* Canon starts here (move to lib at some point) *)

(* using input form so don't have to recalculate every time *)

(* The Earth's mean radius [not polar/equitorial] *)

earthMeanRadius = 6371009/1000;

(* GMST time at Unix day d, given as an angle *)

gmst[d_] = ((-4394688633775234485 + 401095163740318*d)*Pi)/200000000000000;

(* xyz coordinates of lat/lon at time d (in Unix days) compared to
earth geocenter, ignoring precession and assuming spherical Earth *)

latlond2xyz[lat_,lon_,d_] = {earthMeanRadius*Cos[lat]*Cos[gmst[d]+lon],
earthMeanRadius*Cos[lat]*Sin[gmst[d]+lon], earthMeanRadius*Sin[lat]}

(* Given right ascension, declination, latitude, longitude, and Unix
day, return "geocentric" azimuth and elevation *)

raDec2AzEl[ra_,dec_,lat_,lon_,d_] = 

{ArcTan[Cos[lat]*Sin[dec] + Cos[dec]*Sin[lat]*
    Sin[lon + ((11366224765515 + 401095163740318*d)*Pi)/200000000000000 - ra], 
  -(Cos[dec]*Cos[lon + ((11366224765515 + 401095163740318*d)*Pi)/
       200000000000000 - ra])], 
 ArcTan[Sqrt[Cos[dec]^2*Cos[lon + ((11366224765515 + 401095163740318*d)*Pi)/
         200000000000000 - ra]^2 + 
    (Cos[lat]*Sin[dec] + Cos[dec]*Sin[lat]*
       Sin[lon + ((11366224765515 + 401095163740318*d)*Pi)/200000000000000 - 
         ra])^2], Sin[dec]*Sin[lat] - Cos[dec]*Cos[lat]*
    Sin[lon + ((11366224765515 + 401095163740318*d)*Pi)/200000000000000 - ra]]}

(* Canon ends here *)

(* closed form for integrating difference of symbolic arbitrary cosine
function with Chebyshev m-th polynomial with coefficient k (n
represents shift) *)

cs = Table[c[i],{i,0,10}]

temp1[m_] := temp1[m] = Integrate[
 (a+b*Cos[c*(t+2*n)-d]-k*ChebyshevT[m,t])^2, {t,-1,1}]

Integrate[(a+b*Cos[c*(t+2*n)-d]-chebyshev[cs,t])^2,{t,-1,1}]

temp1[m_] := temp1[m] =
Integrate[(a+b*Cos[c*(t+2*n)-d]-chebyshev[Table[c[i],{i,0,m-1}],t])^2,{t,-1,1}]

(* for a list *)

temp2[l_] := temp1[Length[l]] /. c[i_] :> l[[i+1]]

(* note that c[i] goes to l[[i+1]] not l[[i]] *)

(* using raw-venus.m *)

test1 = Partition[coeffs,ncoeff];

temp2[test1[[1]]]

Sum[temp2[test1[[i]]] /. n->Floor[i/3], {i,1,28,3}]

FindMinimum[%, {a,{b,10^8},{c,2*Pi/20},d}]

FindMinimum[%, {a,b,c,d}]

Show[{
Plot[0, {t,-1,9}],
Plot[chebyshev[test1[[1]],t], {t,-1,1}],
Plot[chebyshev[test1[[4]],t-2], {t,1,3}],
Plot[chebyshev[test1[[7]],t-4], {t,3,5}],
Plot[chebyshev[test1[[10]],t-6], {t,5,7}],
Plot[chebyshev[test1[[13]],t-8], {t,7,9}]
}, PlotRange->All]

(* Venus range is 16 days with 10 coeffs, so 1.6 day sample [minimal] starting at -11 ending at 21717 *)

tab0 = Table[poly[x,2,0,t][t], {t,-11,21717,1.6}];

(* for below: 

tab0 = Table[poly[x,2,0,t][t], {t,-11,21717,8}];

Plot[{poly[x,2,0,t][t]-superfourtwo[tab0,5][(t+19)/8]}, {t,-11,21717}]

NIntegrate[(superfourtwo[tab0,1][t]-poly[x,2,0,t][t])^2,{t,-11,21717}]

diffsq[n_] := diffsq[n] = Total[superfourtwoleft[tab0,n]^2]

ListPlot[Log[Table[diffsq[n],{n,1,20}]]/Log[10]/2, PlotJoined->True]

Plot[{poly[x,2,0,t][t]-superfourtwo[tab0,1][(t+19)/8]}, {t,-11,21717}]

tab0 = Table[poly[x,2,0,t][t], {t,-11,21717,0.8}];

Plot[{poly[x,2,0,t][t]-superfourtwo[tab0,1][(t+11.8)/0.8]}, {t,-11,21717}]


FindMinimum[Sum[((a+b*Cos[c*n-d]) - data[[n]])^2, {n,1,Length[data]}],
{{a,Mean[data]},{b,(Max[data]-Min[data])/2},
 {c,numperiods[data]*2*Pi/Length[data]},d},
Method -> Newton
]

tab0 = Table[poly[x,2,0,t][t], {t,-11,21717,0.8}];

Take[Sort[Abs[Fourier[tab0]]],-50]

tab0 = Table[poly[x,2,0,t][t], {t,0,1000,0.1}];


(* more Chebyshev to VSOP, using http://stackoverflow.com/questions/4463481/continuous-fourier-transform-on-discrete-data-using-mathematica *)

planet299 = Drop[planet299, -1];
planet299 = planet299[[1;;Length[planet299];;10]];
test = Table[planet299[[i,3]],{i,1,Length[planet299]}];
Clear[planet299]
Length[test]

(* number of periods in list, roughly *)

fourtwo[l_] :=
FindMinimum[Sum[((a+b*Cos[c*n-d]) - l[[n]])^2, {n,1,Length[l]}],
{{a,Mean[l]},{b,(Max[l]-Min[l])/2},{c,numperiods[l]*2*Pi/Length[l]},d}];

f1[x_] = a+b*Cos[c*x-d] /. fourtwo[test][[2]]
t1 = Table[f1[x],{x,1,Length[test]}];
ListPlot[{t1-test}]

f2[x_] = a+b*Cos[c*x-d] /. fourtwo[test-t1][[2]]
t2 = Table[f2[x],{x,1,Length[test]}];
ListPlot[{t1+t2-test}]

f3[x_] = a+b*Cos[c*x-d] /. fourtwo[test-t1-t2][[2]]
t3 = Table[f3[x],{x,1,Length[test]}];
ListPlot[{t1+t2+t3-test}]

(* test data to get fourtwo working *)

data = Table[N[753+919*Sin[x/623-125]], {x,1,25000,1}]; 

cs = Table[c[i],{i,1,12}]
Integrate[((a+b*Cos[c*x-t])-chebyshev[cs,x])^2,{x,-1,1}]

Ordering[Take[Abs[Fourier[test]],Floor[Length[test]/2]],-1]

N[Integrate[((a+b*Cos[c*t-d])-poly[x,2,0,-3][t])^2,{t,-11,5}]]
N[Integrate[((a+b*Cos[c*t-d])-poly[x,2,0,13][t])^2,{t,5,21}]]

Timing[Integrate[((a+b*Cos[c*t-d])-poly[x,2,0,-3][t])^2,{t,-11,5}]]

piece[n_] := Integrate[
 ((a+b*Cos[c*t-d])-poly[x,2,0,16*n][t])^2,
 {t,16*n-11,16*n+5}]





(* Chebyshev to VSOP? *)

Integrate[Cos[c*t]*poly[x][6][0][t][t],{t,0,60*365}]

(* For mathematica stack *)

(* http://mathematica.stackexchange.com/questions/65045/integrate-over-piecewise-function-defined-using?noredirect=1#comment182208_65045 *)

Piecewise[(DownValues[f][[All, 2]] /. Verbatim[Condition][a_, b_] :> {a, b})]

f[w_] = Piecewise[(DownValues[eval][[All,2]] /.
Verbatim[Condition][a_, b_] :> {a, b})];

t = Table[f[t],{t,10,10+365,.1}]

tab = Table[eval[x,2,0,t],{t,10,10+365*10,.1}];

f[x_] := x /; x<0
f[x_] := x^2 /; x>=0

Integrate[f[x],{x,-1,1}]

Integrate[Cos[n x] f[x], {x, -1, 1}]

Integrate[Cos[c*t+2*i]*ChebyshevT[n,t],{t,-1,1}]

<</home/barrycarter/20140823/raw-jupiter.m

part = Transpose[Partition[coeffs,ncoeff*3]];

tots = Table[Total[i],{i,part}]

(* only first 10 for Venus *)

resp = Table[tots[[i]]*Integrate[Cos[c*t]*ChebyshevT[i-1,t],{t,-1,1}],
{i,1,10}]

test0[c_] = Total[resp]

Plot[test0[c],{c,0.01,100},PlotRange->All]
Plot[test0[c],{c,0.001,.01},PlotRange->All]
Plot[test0[c],{c,1/56,1/14},PlotRange->All]
Plot[test0[c],{c,4,5},PlotRange->All]

(* roughly 4.5 min *)

Plot[Cos[4.5*t],{t,-1,1}]







moon[t_] = {mx[t],my[t],mz[t]}
me[t_] = {x[t],y[t],z[t]}

Solve[(moon[t]-me[t]).me[t]==0, {x[t],y[t],z[t]}]

Solve[(moon[t]-me[t]).me[t]==0, t]



Plot[ArcTan[Tan[3*x]*4],{x,0,Pi/2}]

FullSimplify[raDec2AzEl[ra,dec,lat,lon,d],
{Member[ra,Reals], Member[dec, Reals], Member[lat, Reals], Member[d, Reals],
 Member[lon,Reals]}]

Plot[raDec2AzEl[0,0,35*Degree,0,d][[1]],{d,0,1}]

(* 

Fresh start re ICRF to altaz:

ICRF: 1,0,0 is 0h 0deg
ICRF: 0,0,1 is any h 90deg
ICRF: 0,1,0 is 6h 0deg (or 18h?)

at 0h siderial time, locally

0h0deg is due south 180deg az and 90-lat el
anyh 90 deg is due north 0deg az at lat el [indep of t]
6h 0 deg is due west 270deg az at el 0

so at 0h:

1, 0, 0 -> {-Sin[lat], 0, Cos[lat]}
0, 1, 0 -> {0, -1, 0}
0, 0, 1 -> {Cos[lat], 0, Sin[lat]}

at sidereal hour t:

th0deg is due south 180deg az and 90-lat el
anyh 90 deg is due north 0deg az at lat el [indep of t]
t+6h 0 deg is due east 90deg az at el 0

{Cos[t], Sin[t], 0} -> {-Sin[lat], 0, Cos[lat]}
{0, 0, 1} -> {Cos[lat], 0, Sin[lat]}
{-Sin[t], Cos[t], 0} -> {0, 1, 0}

*)

mat = Table[m[i][j],{i,1,3},{j,1,3}]

mat = mat /. FullSimplify[Solve[{
 mat.{Cos[t], Sin[t], 0} == {-Sin[lat], 0, Cos[lat]},
 mat.{0, 0, 1} == {Cos[lat], 0, Sin[lat]},
 mat.{-Sin[t], Cos[t], 0} == {0, 1, 0} 
}, Flatten[mat]]]

sph2xyz[{th_,ph_,r_}] = r*{Cos[th]*Cos[ph], Sin[th]*Cos[ph], Sin[ph]}
xyz2sph[{x_,y_,z_}] = {ArcTan[x,y], ArcTan[Sqrt[x^2+y^2],z], Norm[{x,y,z}]}

radec2altaz[ra_, dec_] = 
 xyz2sph[Flatten[mat.sph2xyz[{ra,dec,1}]]]

radec2altaz[ra_,dec_,lat_,t_] = 
FullSimplify[radec2altaz[ra,dec], {Member[ra,Reals], Member[dec, Reals],
 Member[lat, Reals], Member[t, Reals]}]

radec2altaz2[ra_,dec_,lat_,lon_,d_] =  Take[
FullSimplify[radec2altaz[ra,dec,lat,gmst[d]+lon]],2]



radec2altaz2[13.75/24*2*Pi, -10.75*Degree, 35*Degree, -106*Degree,
1413925700/86400]/Degree




(* tests *)

N[radec2altaz[0,0,35*Degree,0]/Degree]

N[radec2altaz[0,27*Degree,35*Degree,0]/Degree]

N[radec2altaz[1/24*2*Pi,27*Degree,35*Degree,0]/Degree]

N[radec2altaz[2/24*2*Pi,27*Degree,35*Degree,0]/Degree]

N[radec2altaz[8/24*2*Pi,27*Degree,35*Degree,0]/Degree]

N[radec2altaz[13/24*2*Pi,27*Degree,35*Degree,0]/Degree]

N[radec2altaz[18/24*2*Pi,27*Degree,35*Degree,0]/Degree]

N[radec2altaz[23/24*2*Pi,27*Degree,35*Degree,0]/Degree]










(* TODO: add below to library of some sort *)

(* matrix of rigid rotation around xyz axis *)

rotationMatrix[x,theta_] = {
 {1,0,0}, {0,Cos[theta],Sin[theta]}, {0,-Sin[theta],Cos[theta]}
};

rotationMatrix[y,theta_] = {
 {Cos[theta],0,-Sin[theta]}, {0,1,0}, {Sin[theta],0,Cos[theta]}
};

rotationMatrix[z,theta_] = {
 {Cos[theta],-Sin[theta],0}, {Sin[theta],Cos[theta],0}, {0,0,1}
};

(* CoordinateTransform does NOT do this well *)

test1[ra_,dec_] = sph2xyz[{ra,dec,1}]
test2[ra_, dec_, t_] = rotationMatrix[z,-t].test1[ra,dec]
test3[ra_, dec_, lat_, t_] = rotationMatrix[y, Pi/2-lat].test2[ra,dec,t]
test4[ra_, dec_, lat_, t_] = xyz2sph[test3[ra,dec,lat,t]]

Take[N[test4[0,90*Degree,35*Degree,0]/Degree],{1,2}]
Take[N[test4[0,80*Degree,35*Degree,0]/Degree],{1,2}]

Plot[(test4[0,20*Degree,35*Degree,t]/Degree)[[1]],{t,0,2*Pi}]

test4[(13+40/60)/24*2*Pi, -10.5*Degree, 35*Degree, (12+49/60)/24*2*Pi]/Degree


Solve[sph2xyz[th,ph,r] == {x,y,z}, {th,ph,r}, Reals]




(* breaking it down *)

test1[ra_,dec_] = CoordinateTransform["Spherical" -> "Cartesian", {1,ra,dec}];


test[lat_, sidtime_, ra_, dec_] = Take[N[
CoordinateTransform["Cartesian" -> "Spherical", 
rotationMatrix[y,-lat].
rotationMatrix[z,sidtime] .
CoordinateTransform["Spherical" -> "Cartesian", {1,ra,dec}]
]/Degree,20],{2,3}]

test[35*Degree, 0, 0, 80*Degree]










(* These are temporary variables used to compute formulas above *)

(* position of ra/dec on sphere *)





CoordinateTransform["Polar" -> "Cartesian", {1,ra,dec}]

hourAngle[d_, lon_, ra_] = gmst[d]+lon-ra;


-sin($ha)*cos($dec)

raDecLatLonTime2AzEl[ra_, dec_, lat_, lon_, d_] = 
{ArcTan[Cos[lat]*Sin[dec]-Sin[lat]*Cos[dec]*Cos[hourAngle[d,lon,ra]], 
 -Sin[hourAngle[d,lon,ra]]*Cos[dec]]
}

Plot[raDecLatLonTime2AzEl[0,Pi/2-.0001,35*Degree,-106*Degree,d][[1]],
 {d,16363,16364}]




$ha));

(-sin($ha)*cos($dec),cos($lat)*sin($dec)-sin($lat)*cos($dec)*cos($ha));







(* albuquerque true position at 12 Oct 2014 at 0000 UTC:

location is: 253.349000,35.0836000,0.0000000 [lat/lon/el per NASA]

actual el ~ 1609km, but ok for now

3.123875261913859E+02,-5.216220605699863E+03,3.644794160555919E+03

gmst is 18.697374558 + 24.06570982441908*d

where d is days since 2000 January 1, at 12h UT (Unix second 946728000)

1413072000 = 12 Oct 2014 at 0000 so d= 5397.5000000000

lst is gmst+253.349000/15 or 18.2561

so, assuming circular earth at mean radius 6371.009 km...

*)

z = 6371.009*Sin[35.0836000*Degree]
x = 6371.009*Cos[35.0836000*Degree]*Cos[18.2561/24*2*Pi]
y = 6371.009*Cos[35.0836000*Degree]*Sin[18.2561/24*2*Pi]

(* general formula for position of lat, lon assuming fixed earth
radius, t given in Unix days *)

(* gmst at Unix epoch: *)

Mod[18.697374558 + 24.06570982441908*-10957.5,24]

(* GMST time at Unix day d *)

gmst[d_] = Mod[18697374558/10^9 + 2406570982441908/10^14*(-109575/10+d),24]

emr = 6371009/1000;

N[pos[35.0836*Degree,253.349*Degree,16355],20]

(* abq to moon *)

angle[t_,lat_,lon_] := (earthmoon[t]-pos[lat,lon,t]).pos[lat,lon,t]

Plot[angle[t,35*Degree,-106*Degree],{t,16353,16354}]

FindRoot[angle[t,-106*Degree,lat]==0,{t,16353}]

(* angle of deviation from J2000 *)

Table[ArcTan[Norm[{i[[1]],i[[2]]}], i[[3]]], {i,list}]

(* Fourier using sum of squares *)

f[a_,b_,c_,d_] = Sum[((a+b*Cos[c*n-d]) - l[[n]])^2, {n,1,Length[l]}];

f[a_,b_,c_,d_] = Sum[((a+b*Cos[c*n-d]) - l[[n]])^2, {n,1,5}];

fourtwo[l_] :=
FindMinimum[Sum[((a+b*Cos[c*n-d]) - l[[n]])^2, {n,1,Length[l]}],
{{a,Mean[l]},{b,(Max[l]-Min[l])/2},{c,0},d}];

fourtwo[l_] :=
FindMinimum[Sum[((a+b*Cos[c*n-d]) - l[[n]])^2, {n,1,Length[l]}],
{{a,Mean[l]},{b,(Max[l]-Min[l])/2},{c,-0.0004},d}];



opt[x_] = 45.8469 + 2528.03 Cos[1.371 - 0.000246661 x]

t0 = Table[{l[[x]],opt[x]}, {x,1,Length[l]}];

t0 = Table[opt[x], {x,1,Length[l]}];



NMinimize[f[a,b,c,d],{{a,Mean[l]},b,c,d}]

(* full moon using DE430 *)

(* earth to moon *)

earthmoon[t_] := 
Table[-poly[c][399][3][t][t] + poly[c][301][3][t][t], {c,{x,y,z}}]

(* sun to earth *)

sunearth[t_] := Table[
poly[c][10][0][t][t] - poly[c][3][0][t][t] - poly[c][399][3][t][t],
{c,{x,y,z}}]

Plot[(sunearth[t].earthmoon[t])/Norm[earthmoon[t]]/Norm[sunearth[t]],
{t,16353,16353+30}]

NMaximize[{(sunearth[t].earthmoon[t])/Norm[earthmoon[t]]/Norm[sunearth[t]],
t>16353, t<16353+30}, t, WorkingPrecision -> 50, AccuracyGoal -> 20]

(* answer above is
16366.907155967293762640138985063849844000172257588, or 1414100778 as
a second or Thu Oct 23 15:46:18 MDT 2014; actual time is 15:57 *)

(* 16366.907155965177147329076151874100582632938057038 if using DE431
or 1414100778 so same second *)

NMaximize[{(sunearth[t].earthmoon[t])/Norm[earthmoon[t]]/Norm[sunearth[t]],
t>16353+30, t<16353+60}, t, WorkingPrecision -> 50, AccuracyGoal -> 20]

FindRoot[sunearth[t][[1]] + earthmoon[t][[1]] == 0, {t,16366}]

t0 = 1414100778/86400.
ArcTan[sunearth[t0][[1]], sunearth[t0][[2]]]
ArcTan[earthmoon[t0][[1]], earthmoon[t0][[2]]]

t1 = t0+11/1440;
ArcTan[sunearth[t1][[1]], sunearth[t1][[2]]]
ArcTan[earthmoon[t1][[1]], earthmoon[t1][[2]]]

NMinimize[{(sunearth[t].earthmoon[t])/Norm[earthmoon[t]]/Norm[sunearth[t]],
t>16345, t<16353}, t, WorkingPrecision -> 50, AccuracyGoal -> 20]

NMaximize[{(sunearth[t-499.0/86400].earthmoon[t])/
 Norm[earthmoon[t]]/Norm[sunearth[t-499/86400]],
t>16353+30, t<16353+60}, t, WorkingPrecision -> 50, AccuracyGoal -> 20]

sunearth[16353]

ArcTan[sunearth[16353][[1]], sunearth[16353][[2]]]
ArcSin[sunearth[16353][[3]]/Norm[sunearth[16353]]]

Table[-poly[c][399][3][t][t] + poly[c][301][3][t][t], {c,{x,y,z}}]

ArcTan[earthmoon[16353][[1]], earthmoon[16353][[2]]]

(* above is 35 degrees, or about 2+ hours RA *)

ArcSin[earthmoon[16353][[3]]/Norm[earthmoon[16353]]]

(* above also close though less so than Id like vs stellarium *)

(* nutations *)

(* section 570: 1999-10-21 00:00:00 to 1999-11-22 00:00:00, 571: ends
1999-12-24 00:00:00, so 572 is the one including 2000-01-01 *)

Plot[chebyshev[Take[coeffs, {1+20*572,10+20*572}],t],{t,-1,1}]

nums = N[{
chebyshev[Take[coeffs, {1+20*572,10+20*572}],-1/2],
chebyshev[Take[coeffs, {11+20*572,20+20*572}],-1/2]
}, 20]

(* polynomial equations *)

f[t_] = x /. Solve[x^7+x+1==t, x][[1]]

Plot[f[t],{t,-1,1}]

(* finding the equatorial plane after precession *)

planeFromPoints[{x0_,y0_,z0_},{x1_,y1_,z1_},{x2_,y2_,z2_}] = 
{a,b,c} /.
 Solve[{a*x0+b*y0+c*z0==1, a*x1+b*y1+c*z1==1, a*x2+b*y2+c*z2==1}, {a,b,c}][[1]]

(* e = epsilon = derivative *)

planeFromPoints[{x,y,z}, {e,e,e}, {x+e,y+e,z+e}]


(* simple moonrise/set at Albuquerque on day 16349ish *)

(* position of moon from geocenter *)

moon[t_] = Table[{poly[i][301][3][t][t] - poly[i][399][3][t][t]},{i,{x,y,z}}]

(* position of Albuquerque from geocenter at siderial time t (different t) *)

abq[t_] = {6371009/1000*Cos[35*Degree]*Cos[t/12*Pi],
           6371009/1000*Cos[35*Degree]*Sin[t/12*Pi],
           6371009/1000*Sin[t/12*Pi]
	   }

(* dot product wrt fixed moon position *)

Plot[abq[t].moon[16355], {t,0,24}]

(* precession comps *)

test2 = Drop[test,-1]

xprecess = Table[{(n-1)*30, test2[[n,1]]}, {n,1,Length[test2]}]
yprecess = Table[{(n-1)*30, test2[[n,2]]}, {n,1,Length[test2]}]

xvals = Table[i[[1]], {i,test2}]

x1[t_] = Fit[xprecess, {1,t}, t]

yprecess = Table[{(n-1)*30, test2[[n,2]]}, {n,1,Length[test2]}]
yvals = Table[i[[2]], {i,test2}]
y1[t_] = Fit[yprecess, {1,t}, t]
approxy = Table[y1[t], {t,0,36510,30}]
erry = yvals-approxy
y2[t_] = FullSimplify[Chop[superfour[erry,1][t/30+1]]]
approxy2 = Table[y1[t]+y2[t], {t,0,36510,30}]
ListPlot[yvals-approxy2]

zprecess = Table[{(n-1)*30, test2[[n,3]]}, {n,1,Length[test2]}]
zvals = Table[i[[3]], {i,test2}]
z1[t_] = Fit[zprecess, {1,t}, t]
approxz = Table[z1[t], {t,0,36510,30}]
errz = zvals-approxz
z2[t_] = FullSimplify[Chop[superfour[errz,1][t/30+1]]]
approxz2 = Table[z1[t]+z2[t], {t,0,36510,30}]
ListPlot[zvals-approxz2]

approx1 = Table[f1[x], {x,0,36510,30}]

err1 = xvals-approx1

f2[x_] = FullSimplify[Chop[superfour[err1,1][x/30+1]]]

approx2 = Table[f1[x]+f2[x], {x,0,36510,30}]

ListPlot[xvals-approx2]

superfour[xprecess-approx1,1]


xprecess = Table[i[[1]], {i,test2}]

Fit[xprecess, {1,x}, x]

approx = Table[% /. x-> i, {i,1,Length[test2]}]

ListPlot[{approx-xprecess}]

superfour[approx-xprecess, 1]

approx2 = Table[%[x] /. x-> i, {i,1,Length[test2]}]

ListPlot[{xprecess-approx+approx2}, PlotJoined->True]

(* xyz at given lst *)

(* mean earth radius *)
mer = 6371009/1000;

(* albuquerque latitude, per NASA *)
abqlat = 35.0836000*Degree

z[lat_] = mer*Sin[lat]

(* radius of the Earth at latitude lat, since Earth is not perfectly spherical; from http://en.wikipedia.org/wiki/Earth_radius#Radius_at_a_given_geodetic_latitude (and agrees closely w/ HORIZONS to within a few mm) *)

num = (a^2*Cos[lat])^2 + (b^2*Sin[lat])^2 
den = (a*Cos[lat])^2 + (b*Sin[lat])^2 
rad[lat_] = Sqrt[num/den] /. {a -> 63781370/10000, b -> 63567523/10000} 

(* below is input form, after simplification *)

rad[lat_] = Sqrt[8108893139432429 - 32876703150355522144690902360200/
    (8108893139432429 + 27233178721371*Cos[2*lat])]/10000




(* Mercury below *)

Plot[poly[x][1][0][t][t], {t,16071,16071+365}]

ParametricPlot[{raw[x][1][0][16342][t],raw[y][1][0][16342][t]}, {t,-1,1}, 
AxesOrigin->{0,0}]

tab = Table[{t,poly[x][1][0][t][t]}, {t,16071,16071+365,22}]

f = Interpolation[tab]

Plot[f[t]-poly[x][1][0][t][t], {t,16071,16071+365}, PlotRange->All]

Plot[{f[t],poly[x][1][0][t][t]}, {t,16071,16071+365}, PlotRange->All]

p[x_] = InterpolatingPolynomial[tab, x]

CoefficientList[p[x],x] - CoefficientList[poly[x][1][0][16071][t],t]

Plot[p[x], {x,1,Length[tab]}]



(* fit polynomial of lowest degree to given points = InterpolatingPolynomial *)

(* best fit circle to function *)

(* Given three functions representing x[t], y[t], z[t], and an
interval [a,b], find the center and radii of the best fit circle *)

functionsToCircle[x_, y_, z_, a_, b_] := Module[{x0,y0,z0,val},
 (* Integrate radius squared wrt arb point *)
 val = Integrate[(x[t]-x0)^2+(y[t]-y0)^2+(z[t]-z0)^2, {t,a,b}];
 (* Minimize wrt arb points using derivative *)
 Solve[D[val,x0] == 0, x0];

]

ParametricPlot[{poly[x][4][0][t][t], poly[y][4][0][t][t]}, {t,10957,10957+687}]

x[t_] := poly[x][4][0][t][t];
y[t_] := poly[y][4][0][t][t];
z[t_] := poly[z][4][0][t][t];
a = 10957;
b = a+687;

val = Integrate[(x[t]-x0)^2+(y[t]-y0)^2+(z[t]-z0)^2, {t,a,b}]; 

val = Integrate[poly[x][4][0][10957][t],{t,a,a+1}]

test3 = Integrate[(poly[7,1,t]-x0)^2 + (poly[7,2,t]-y0)^2 + (poly[7,3,t]-z0)^2,

(* mars from earth, given DE430 arrays 3, 4, and 12 *)

(* last decade = 10957 to 14610 *)

Plot[poly[x][4][0][t][t] - (poly[x][3][0][t][t] + poly[x][399][3][t][t]),
{t,10957,14610}]




Plot[ArcTan[
poly[x][4][0][t][t] - (poly[x][3][0][t][t] + poly[x][399][3][t][t]),
poly[y][4][0][t][t] - (poly[y][3][0][t][t] + poly[y][399][3][t][t])],
{t,10957,14610}]


ParametricPlot[{
poly[x][4][0][t][t] - (poly[x][3][0][t][t] + poly[x][399][3][t][t]),
poly[y][4][0][t][t] - (poly[y][3][0][t][t] + poly[y][399][3][t][t])},
{t,10957,10957+365*2.14}]

(* best fit circle [evolute] from polynomial *)

<</home/barrycarter/20140823/raw-jupiter.m

part = Partition[Partition[coeffs,ncoeff],3];

(* We may actually need the polys themselves, so store them *)

(* i = 1,2,3 to identify axis *)

Table[poly[n,i,t_] = chebyshev[part[[n,i]],t], {i,1,3}, {n,1,Length[part]}];

test3 = Integrate[(poly[7,1,t]-x0)^2 + (poly[7,2,t]-y0)^2 + (poly[7,3,t]-z0)^2,
{t,-1,1}]
test4 = D[test3, x0]
test6 = Solve[test4==0, x0]
test5 = x0 /. test6[[1]]

(* simpler case *)

Integrate[(x0-x)^2 + (Sin[x]-y0)^2, {x,0,Pi}]

Integrate[(poly[7,1,t]-x0)^2 + (poly[7,2,t]-y0)^2 + (poly[7,3,t]-z0)^2,
{t,-1,1}]

(* testing with arb polys *)

x[t_] = Sum[a[i]*t^i,{i,0,5}]
y[t_] = Sum[b[i]*t^i,{i,0,5}]
z[t_] = Sum[c[i]*t^i,{i,0,5}]

Integrate[(x[t]-x0)^2 + (y[t]-y0)^2 + (z[t]-z0)^2, {t,-1,1}]
D[%, x0]
Solve[%==0, x0]

test0 = Integrate[(x[t]-x0)^2 + (y[t]-y0)^2 + (z[t]-z0)^2, {t,p0,p0+dt}]
test1 = D[test0, x0]
test2 = x0 /. Solve[test1==0, x0][[1]]

Integrate[(x[t]-x0)^2 + (y[t]-y0)^2 + (z[t]-z0)^2, {t,-1,0}]
D[%, x0]
Solve[%==0, x0]

(* more best fit ellipse stuff *)

Integrate[
 Norm[{x[t]-x0, y[t]-y0, z[t]-z0}] + 
 Norm[{x[t]-x1, y[t]-y1, z[t]-z1}] -
 c, t]

(* using results to find pos of mercury "today", day 16334 *)

t = 16334;

x[t_] := poly[x][5][0][t][t]
y[t_] := poly[y][5][0][t][t]
z[t_] := poly[z][5][0][t][t]

Integrate[
 Norm[{x[t]-x0, y[t]-y0, z[t]-z0}] + 
 Norm[{x[t]-x1, y[t]-y1, z[t]-z1}] -
 c, {t,16333,16335}]

Integrate[
 Norm[{x[t]-x0, y[t]-y0, z[t]-z0}]^2,
{t,16333,16335}]

Integrate[Norm[poly[x][5][0][16334][w]-x0], {w,16333,16335}]

(* testing with arb polys *)

x[t_] = Sum[a[i]*t^i,{i,0,5}]
y[t_] = Sum[b[i]*t^i,{i,0,5}]
z[t_] = Sum[c[i]*t^i,{i,0,5}]

Integrate[
 Norm[{x[t]-x0, y[t]-y0, z[t]-z0}] + 
 Norm[{x[t]-x1, y[t]-y1, z[t]-z1}],
t]

(* 3 is technically barycenter *)

ArcTan[
poly[x][5][0][t][w] - poly[x][3][0][t][w],
poly[y][5][0][t][w] - poly[y][3][0][t][w]
]

Normal[Series[%, {w,t,5}]]

Plot[%, {w,t,t+1}]



ArcTan[
 x[1,0,t] - (x[399,3,t] + x[3,0,t]),
 y[1,0,t] - (y[399,3,t] + y[3,0,t])
]

ArcTan[
 (y[1,0,t] - (y[399,3,t] + y[3,0,t]))/
 (x[1,0,t] - (x[399,3,t] + x[3,0,t]))
]

z[1,0,t] - (z[399,3,t] + z[3,0,t])

Norm[{x[1,0,t] - (x[399,3,t] + x[3,0,t]), y[1,0,t] - (y[399,3,t] + y[3,0,t]),
 z[1,0,t] - (z[399,3,t] + z[3,0,t])}]

ArcSin[(z[1,0,t] - (z[399,3,t] + z[3,0,t])) /
Norm[{x[1,0,t] - (x[399,3,t] + x[3,0,t]), y[1,0,t] - (y[399,3,t] + y[3,0,t]),
 z[1,0,t] - (z[399,3,t] + z[3,0,t])}]
]

Plot[
ArcTan[
 x[1,0,t] - (x[399,3,t] + x[3,0,t]),
 y[1,0,t] - (y[399,3,t] + y[3,0,t])
],
{t,16071,16071+365}
]




(* 2D ellipse using alternate form (normalized) *)

ellipse[x_,y_] = a*x^2+b*x*y+c*y^2+d*x+e*y+1

coords = Table[ellipse[x[i],y[i]]==0,{i,1,5}]

Solve[%, {a,b,c,d,e}]

(* 2D ellipse using NSolve *)

coords = Table[{x[i],y[i]},{i,1,4}]

Table[{x[i] = Random[], y[i] = Random[]}, {i,1,4}]

dists = Table[Norm[i-{fx,fy}] + Norm[i-{gx,gy}], {i,coords}]

NSolve[dists[[1]] == dists[[2]] == dists[[3]] == dists[[4]]]

(* 2D circle *)

coords = Table[{x[i],y[i]},{i,1,3}]
dists = (Table[Norm[i-{cx,cy}], {i,coords}])^2

Solve[dists[[1]]==dists[[2]]==dists[[3]], {cx,cy}, Reals]

circFromPoints[{x0_,y0_},{x1_,y1_},{x2_,y2_}] = 
 {cx,cy} /. Solve[Norm[{x0,y0}-{cx,cy}]^2 == Norm[{x1,y1}-{cx,cy}]^2 == 
 Norm[{x2,y2}-{cx,cy}]^2, {cx,cy}, Reals][[1]]

circFromPoints[{0,0},{3,4},{5,6}]

circFromPoints[{x0_,y0_,z0_},{x1_,y1_,z1_},{x2_,y2_,z2_}] = 
 {cx,cy,cz} /. Solve[Norm[{x0,y0,z0}-{cx,cy,cz}]^2 == 
                     Norm[{x1,y1,z1}-{cx,cy,cz}]^2 == 
                     Norm[{x2,y2,z2}-{cx,cy,cz}]^2, 
{cx,cy,cz}, Reals][[1]]

(* ellipse using NSolve *)

coords = Table[{x[i],y[i],z[i]},{i,1,4}]

(* this table is used just for assignment *)

Table[{x[i] = Random[], y[i] = Random[], z[i] = Random[]}, {i,1,4}]

dists = Table[Norm[i-{fx,fy,fz}] + Norm[i-{gx,gy,gz}], {i,coords}]

NSolve[dists[[1]] == dists[[2]] == dists[[3]] == dists[[4]]]

(* Find plane given 3 points *)

coords = Table[{x[i],y[i],z[i]},{i,1,3}]

(* equation of a plane *)

Solve[Table[a*j[[1]]+b*j[[2]]+c*j[[3]]==1, {j,coords}], {a,b,c}]

planeFromPoints[{x0_,y0_,z0_},{x1_,y1_,z1_},{x2_,y2_,z2_}] = 
{a,b,c} /.
 Solve[{a*x0+b*y0+c*z0==1, a*x1+b*y1+c*z1==1, a*x2+b*y2+c*z2==1}, {a,b,c}][[1]]



(* Find ellipse in 2D given points on perimeter *)

coords = Table[{x[i],y[i]},{i,0,4}]

(* wlog, can assume one point is origin, other on x axis *)

x[0] = 0; y[0] = 0; y[1] = 0;

(* distance from two foci summed [ie, a constant] *)

dists = Table[Norm[i-{fx,fy}] + Norm[i-{gx,gy}], {i,coords}]

(* the squared dists *)

dists2 = Expand[dists^2];

sol1 = Expand[Solve[dists2[[1]]-dists2[[2]] == 0, {fx,fy,gx,gy}][[1]]];
gy = gy /. sol1

sol2 = Solve[dists2[[2]] - dists2[[3]] == 0, {fx,fy,gx}][[1]];

(* Find ellipse given points on perimeter *)

coords = Table[{x[i],y[i],z[i]},{i,1,3}]

(* distance from two foci summed [ie, a constant] *)

dists = Table[Norm[i-{fx,fy,fz}] + Norm[i-{gx,gy,gz}], {i,coords}]

sol1 = Solve[dists[[1]] == dists[[2]], {fx,fy,fz,gx,gy,gz}, Reals][[1]];
gz = gz /. sol1

sol2 = Solve[dists[[2]] == dists[[3]], {fx,fy,fz,gx,gy}][[1]];

(* Given a parametrized ellipse, find area from focus *)

x[t_,a_,b_] = a*Cos[t]
y[t_,a_,b_] = b*Sin[t]

(* area from center is abt/2 (surprisingly?); from focus, we subtract
off triangle *)

areafromfocus[t_,a_,b_] = a*b*t/2 - Sqrt[a^2-b^2]*b*Sin[t]/2

tfromarea[area_,a_,b_] := t /. FindRoot[areafromfocus[t,a,b]-area, {t,0,Pi}]

xfromarea[area_,a_,b_] := x[tfromarea[area,a,b],a,b]

ri[area_,m_,n_] := RationalInterpolation[
 xfromarea[area,1.1,1],
 {area,m,n},{area,0,Pi}]

maxdiff[m_,n_] := NMaximize[{xfromarea[area,1.1,1]-ri[area,m,n], 
 area>0, area<Pi}, area]

tab = Table[{n,m,maxdiff[m,n][[1]]},{m,0,10},{n,0,10}]

Table[i[[3]],{i,Flatten[tab,1]}]

2.11377*10^-7 is smallest

Plot[ArcCos[xfromarea[area,1.1,1]/1.1],{area,0,1.1/2*Pi}]

Plot[ArcCos[xfromarea[area,1.1,1]/1.1],{area,0,1.1/2*Pi}]

Plot[xfromarea[area,1.1,1],{area,0,1.1/2*Pi}]

Plot[Tan[xfromarea[area,1.1,1]],{area,0,1.1/2*Pi}]

RationalInterpolation[Tan[xfromarea[area,1.1,1]], {area,2,0},{area,0,Pi}]

Plot[{%-Tan[xfromarea[area,1.1,1]]},{area,0,1.1/2*Pi}]

ecc = 2;
RationalInterpolation[tfromarea[area,ecc,1], {area,10,0}, {area,0,Pi}]
Plot[{%-tfromarea[area,ecc,1]}, {area,0,Pi}, PlotRange->All]
showit

test0[area]-ri[area],area>0,area<Pi},area]

Plot[{test0[area]-ri[area]},{area,0,Pi},PlotRange->All]
showit

Plot[ArcCos[xfromarea[area,2,1]/2], {area,0,Pi}]

Plot[xfromarea[area,2,1],{area,0,Pi}]


list = Table[1/i,{i,1,5}]

tay = Table[t^i,{i,0,4}]

Total[list*tay]

Plot[%,{t,-1,1}]

tailortaylor[list,4]

Total[%[[3]]*tay]




(* Chebyshev or Taylor packing *)

mdec = Table[{AstronomicalData["Moon", {"Declination", DateList[t]}]},
 {t, AbsoluteTime[{2014,1,1}], AbsoluteTime[{2015,1,1}], 300}];

mdec2 = Table[AstronomicalData["Moon", {"Declination", DateList[t]}],
 {t, AbsoluteTime[{2014,1,1}], AbsoluteTime[{2015,1,1}], 3600}];

t[n_] := Sum[((i-4381)/4380)^n*mdec2[[i]],{i,1,Length[mdec2]}];

Table[t[i],{i,1,125}]*Table[t^i,{i,1,125}]

(* data packing *)

(* coeffs = Partition[coeffs,14]; *)

cheb2truetay = CoefficientList[Sum[a[i+1]*ChebyshevT[i,x],{i,0,ncoeff-1}],x]

(* with Mercury data loaded *)

(* mercury = Partition[coeffs,14]; *)

(* below for moon compared to earth *)

planet = Partition[coeffs,ncoeff];

newcoff = Table[cheb2truetay /. a[n_] -> planet[[i,n]],{i,1,Length[planet]}];

(* decimeter-level precision *)
newcoff2 = Round[1000000*newcoff];

new2 = Partition[Flatten[newcoff2],ncoeff*3];

new2 = Transpose[new2];

test3 = Table[{i,1+2*Max[Abs[new2[[i]]]]}, {i,1,Length[new2]}]

Table[Ceiling[Log[test3[[i,2]]]/Log[256]], {i,1,Length[test3]}]

(* bytes required given precision level:

km: 78 bytes
m: 129 bytes
dm: 147 bytes
cm: 164 bytes
mm: 179 bytes
um: 233 bytes

*)

(* Earth pos *)

(* moongeo.m and earthmoon.m loaded *)

earthmoon = Partition[Partition[earthmoon,13],3];
moongeo = Partition[Partition[moongeo,13],3];

earthmoon[[23394]][[1]]
moongeo[[23394]][[1]]


(* Chebyshev to Taylor *)

cheb[x_] = Sum[c[i+1]*ChebyshevT[i,x],{i,0,13}]
taylor = Table[t^i,{i,0,13}]

temp1[a_,b_] = CoefficientList[cheb[a+frac*(b-a)],frac]

random = Table[Random[],{i,1,14}]

rand1[x_] = cheb[x] /. c[i_] -> random[[i]]

Plot[rand1[x],{x,-1,1}]

(* The Taylor series for the right hand side *)

rand2[t_] = Total[(temp1[0.4,0.6] /. c[i_] -> random[[i]])*taylor]

Plot[rand2[t],{t,0,1}]

(* TODO: assuming a and b are global below, fix *)

(* parametric ellipse *)

a = 2; b = 1;

(* below parametrizes an ellipse but NOT by angle, as we shall see *)

x[t_] = a*Cos[t]
y[t_] = b*Sin[t]
focus[a_,b_] = Sqrt[a^2-b^2]


(* the ellipse, top right part *)
g1 = ParametricPlot[{x[t],y[t]},{t,0,Pi/2}]

(* "randomly" chosen value of t to show it doesnt match theta *)

(* t is NOT measured in degrees; degrees below is for convenience only *)

samp = 55*Degree

(* the lines from ellipse center and x/y axes to point, and angle arc *)
g2 = {
 Line[{{0,0},{x[samp],y[samp]}}],
 Circle[{0,0}, 2/10, {0, ArcTan[x[samp],y[samp]]}],
 Dashing[0.01],
 Line[{{0,0},{x[samp],y[samp]}}], 
 Dashing[0.01], 
 Line[{{x[samp],0},{x[samp],y[samp]}}], 
 Line[{{0,y[samp]},{x[samp],y[samp]}}],
 Text[Style["b*Sin[t]", FontSize->25], {x[samp], y[samp]/2}, {-1.1,0}],
 Text[Style["a*Cos[t]", FontSize->25], {x[samp]/2, y[samp]}, {0,-1.1}],
 Text[Style["\[Theta]", FontSize->25], {0.2,0.05}, {-1,-1}]
} 


Graphics[TeXForm[Text[Style["b*Sin[t]", FontSize->25]], {0,0}, {-1.1,0}]]
 
(* area from focus, less eccentric ellipse here *)
g3 = {
 Line[{{focus[a,b],0},{x[samp],y[samp]}}],
 Circle[{focus[a,b],0}, 1/20, {0, ArcTan[x[samp]-focus[a,b],y[samp]]}],
 Dashing[0.01], 
 Line[{{x[samp],0},{x[samp],y[samp]}}], 
 Line[{{0,y[samp]},{x[samp],y[samp]}}],
 Text[Style["b*Sin[t]", FontSize->25], {x[samp], y[samp]/2}, {-1.1,0}],
 Text[Style["a*Cos[t]", FontSize->25], {x[samp]/2, y[samp]}, {0,-1.1}],
 Text[Style["\[Theta]", FontSize->25], {focus[a,b],0.05}, {-1,-1}]
} 
 
Show[g1,Graphics[g3]]
showit

(* we see than tan(theta) = (b*Sin[t])/(a*Cos[t]), solving for t *)

(* Mathematica solves below poorly, so doing my own formula *)

(* Solve[Tan[theta] == (b*Sin[t])/(a*Cos[t]), t] *)

t[theta_] = ArcTan[a*Tan[theta]/b]

(* We can now reparametrize *)
x[theta_] = a*Cos[t[theta]]
y[theta_] = b*Sin[t[theta]]

(* We now have y[theta]/x[theta] == Tan[theta], as desired *)

(* the radius squared at theta *)
r2[theta_] = x[theta]^2 + y[theta]^2

(* this takes forever to compute, so hardcoding it after getting result *)

(* parea[theta_] = Integrate[r2[x]/2,{x,0,theta}] *)

parea[theta_] = a*b*ArcTan[a*Tan[theta]/b]/2

a = 2; b = 1;
ParametricPlot[{x[t],y[t]} /. {a->2,b->1},{t,0,Pi/2}]

Solve[Tan[theta] == (b*Sin[t])/(a*Cos[t]), theta]
Solve[Tan[theta] == (b*Sin[t])/(a*Cos[t]), theta, Reals]


(* +-Sqrt[3] are really focii? yup! *)

Sqrt[(x[t]-Sqrt[3])^2 + y[t]^2] + Sqrt[(x[t]+Sqrt[3])^2 + y[t]^2]


(* try drawing the problem out a bit *)


g2 = Labeled[Point[{{0,0}, {Sqrt[3],0}, {-Sqrt[3],0}}], "foo"]

g3 = Labeled[Point[{0,0}], Text["foo"]]

Show[g1,Graphics[g2]]

(* polar coordinates area from origin *)

parea[t_] = Integrate[(x[theta]^2+y[theta]^2)/2, {theta,0,t}]

(* area from focus is area from center minus triangle *)

area[t_] = parea[t] - y[t]*Sqrt[a^2-b^2]/2

Normal[InverseSeries[Series[parea[t], {t,0,15}]]]

(* below is unrelated *)

r*Sin[theta] == Exp[(-r*Cos[theta])^2]

Log[r] + Log[Sin[theta]] == (-r*Cos[theta])^2

(* t, given x or y [top half of ellipse only] *)

(* more work done below 12 Sep 2014 *)

x[t_,a_,b_] = a*Cos[t]
y[t_,a_,b_] = b*Sin[t]
tx[x_,a_,b_] = ArcCos[x/a]
ty[y_,a_,b_] = ArcSin[y/b]

(* y given x *)

yofx[x_,a_,b_] = y[tx[x,a,b],a,b]

(* area swept out from center *)

(* triangle part *)

triarea[t_,a_,b_] = x[t,a,b]*y[t,a,b]/2

(* the general integral *)

genint[x_] = Integrate[yofx[x,a,b],x]

(* with our limits *)

remainder[t_,a_,b_] = FullSimplify[genint[a]-genint[a*Cos[t]], t>0 && t<Pi]

(* complete area from focus at time t *)

parea[t_] = FullSimplify[remainder[t,a,b]+triarea[t,a,b], t>0 && t<Pi]

(* rest *)

Integrate[yofx[x,a,b],{x,a*Cos[t],a}] /; {t>0, t<Pi, x<a, x>-a}


(* need general intgrl here, Mathematica is bad about definite integral here *)

f[x_] = Integrate[yofx[x],x]

restarea[t_] = FullSimplify[f[a] - f[x[t]], Member[{a,b,t}, Reals]]

(* below is just abt/2, wow! *)

totalarea[t_] = FullSimplify[triarea[t] + restarea[t], Member[{a,b,t},Reals]]

(* these simplifications only apply sometimes, but ... *)

totalarea[t] /. {Sqrt[Sin[t]^2] -> Sin[t]}

(* area from focus is area from center minus triangle *)

areafromfocus[t_] = a*b*t/2 - y[t]*Sqrt[a^2-b^2]/2

areafromfocus'[t]
areafromfocus''[t]
areafromfocus'''[t]
areafromfocus''''[t]
areafromfocus'[t]/areafromfocus'''[t]

(* for a given a and b, these nsolve routines work *)

tfromarea[area_,a_,b_] := NSolve[areafromfocus[t] /. {a->a, b->b} == area]



test0 = Table[{areafromfocus[t],x[t]}, {t,0,Pi,.01}] /. {a->1.2,b->1}
ParametricPlot[{areafromfocus[t], x[t]} /. {a->1.2,b->1}, {t,0,Pi}]




Plot[areafromfocus[t]/t /. {a->1.1, b->1}, {t, 0, Pi}]

Solve[Normal[Series[areafromfocus[t]/t, {t, 0, 3}]]==c, t]

Solve[Normal[Series[areafromfocus[t]/t, {t, 0, 5}]]==c, t]

Solve[Normal[Series[areafromfocus[t]/t, {t, 0, 7}]]==c, t]

Solve[areafromfocus[t] == c, t]



(* confirms area of ellipse, top half *)
Integrate[yofx[x],{x,-a,a}]



(* the x value of the rightmost focus *)
(* this can only work when a >= b? *)

focus[a_,b_] = Sqrt[a^2-b^2]

(* angle theta from rightmost focus *)

Solve[ theta == ArcTan[a*Cos[t]/b*Sin[t]], t, Reals]

(* area of triangle connecting rightmost focus to ellipse *)

area[t_] = (x[t]-focus[a,b])*y[t]

(* quadrant specific below *)

yofx[x_] = b*Sin[ArcCos[x/a]]

curvearea[t_] := Integrate[yofx[x],{x, x[t], x[0]}]

totalarea[t_] := curvearea[t] + area[t]



f[t_]=Sqrt[(x[t]-focus[a,b])^2 + y[t]^2] + Sqrt[(x[t]+focus[a,b])^2 + y[t]^2]-4

FullSimplify[f[t], {Element[t,Reals]}]


ParametricPlot[{x[t],y[t]},{t,0,2*Pi}]

d[t_] = Sqrt[(x[t]+x0)^2 + y[t]^2] + Sqrt[(x[t]-x0)^2 + y[t]^2]

d[t] /. {x1 -> -x0, y0 -> 0, y1 -> 0}






ParametricPlot[{x[t],y[t]},{t,0,2*Pi},AspectRatio->Automatic]


(* based on the output of bc-read-cheb.pl for mercury x values 2014 *)

(* this is the file with the output of bc-read-cheb.pl *)
<</tmp/math.m

jds = mercury[x][1][[1]]
jde = mercury[x][48][[2]]

(* the first 2 list elts are start/end Julian date *)

tab = Table[Function[t,Evaluate[
Sum[mercury[x][i][[n]]*ChebyshevT[n-3,t], {n,3,Length[mercury[x][i]]}]]],
{i,1,48}]

(* continous Fourier? *)

f3[k_] = Integrate[tab[[1]][t]*Exp[2*Pi*I*k*t],{t,-1,1}]
maxk = k /. Maximize[Abs[f3[k]],k][[2]]



Plot[tab[[1]][t]/Cos[


(* trivial function that converts a number from [s,e] to [-1,1] *)
f1[t_,s_,e_] = 2*(t-s)/(e-s)-1
(* its inverse: [-1,1] to [s,e] *)
f2[t_,s_,e_] = s + (t+1)*(e-s)/2

g[t_] = Piecewise[
Table[{tab[[i]][f1[t,mercury[x][i][[1]],mercury[x][i][[2]]]], 
 mercury[x][i][[1]] <= t <= mercury[x][i][[2]]}, {i,1,Length[tab]}]
]

Plot[g[t],{t,jds,jde}]

<</home/barrycarter/BCGIT/MATHEMATICA/cheb1.m

(* coeffs stretched to length 15 (my fault when writing cheb1) *)

chebcoff[n_] := PadRight[Take[mercury[x][n], {3,16}],15]

(* combining in pairs *)

t3 = Table[Take[cheb1[chebcoff[i],chebcoff[i+1]],14],{i,1,47,2}]

t4 = Table[{list2cheb[t3[[i]]][
 f1[t, mercury[x][i*2-1][[1]], mercury[x][i*2][[2]]]
],
 mercury[x][i*2-1][[1]] <= t <= mercury[x][i*2][[2]]}, {i,1,Length[t3]}]

k[t_] = Piecewise[t4]

Plot[k[t]-g[t],{t,jds,jde},PlotRange->All]

(* intentionally chopping at 14, though cheb1 gives 30 *)

test1[x_] = list2cheb[Take[cheb1[chebcoff[1],chebcoff[2]],14]]

test2[x_] = test1[f1[x,jds,jds+16]]

Plot[{test2[x]-g[x]},{x,jds,jds+16}]

PadRight[mercury[x][1],15]
PadRight[mercury[x][2],15]

Plot[{tab[[1]][t*2-1],tab[[2]][t*2+1]},{t,-1,1}]
showit

f[t_] = Piecewise[{{tab[[1]][t], t <= 1}, {tab[[2]][t-2], t > 1}}]
Plot[f[x],{x,-1,3}]
showit

g[t_] = Piecewise[Table[{tab[[i]][t+2-2*i], t < -1 + 2*i},{i,1,Length[tab]}]]

Plot[g[t],{t,-1,95}]
