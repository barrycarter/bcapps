(* Canon starts here (move to lib at some point) *)

(* using input form so don't have to recalculate every time *)

(* The Earth's mean radius [not polar/equitorial] *)

earthMeanRadius = 6371009/1000;

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

(* yet more precession *)

rotationMatrix[z,zr].rotationMatrix[y,yr].{0,0,epr}/epr

yrs = Table[{i[[1]],ArcCos[i[[2,3]]/Norm[i[[2]]]]},{i,-Drop[list,-1]}];

(* note: -yrs is also a candidate here *)

ListPlot[{Transpose[yrs][[2]], -Transpose[yrs][[2]]}]

(* ABQ in 2100, z coord is consistently positive (after flip) *)

rotationMatrix[y,yr].latlond2xyz[35.0836000*Degree,253.349000*Degree,47482] /.
yr -> -yrs[[12098]][[2]]

(* year 4100 *)

(* the negative value appears to be the correct one *)

(* 11998 is max value for yrs *)

zrs = Table[{list[[i,1]],
ArcCos[list[[i,2,1]]/Sin[yrs[[i,2]]]/Norm[list[[i,2]]]]}, 
 {i,Length[list]-1}];

(* zrs, 11999 is good; 11997 is arguably good *)

(* 20141128.2038: this is best I have for now and it works *)

(* THIS DOES NOT CORRECT FOR SIGN! *)

zrs2 = Table[If[i<=11998,zrs[[i]],{zrs[[i,1]],yrs[[i,2]]}-Pi],  
 {i,Length[yrs]}];

ListPlot[Take[Drop[zrs2,{11900,12000}],{11700,12100}]]

yrs2 = Table[If[i<=11998,yrs[[i]],{yrs[[i,1]],2*Pi-yrs[[i,2]]}],  
 {i,Length[yrs]}];

zrtest[x_] = Fit[zrs2,{1,x,x^2},x]

yrtest[x_] = Fit[yrs2,{1,x,x^2},x]

zrt2102 = Table[{i,zrtest[i]},{i,Transpose[zrs2][[1]]}];

Transpose[zrs2][[2]]-Transpose[zrt2102][[2]]

rotationMatrix[z,-zrtest[2456934.500000000]].
rotationMatrix[y,Pi-yrtest[2456934.500000000]].
latlond2xyz[35.0836000*Degree,253.349000*Degree, 16347]

rotationMatrix[z,-zrtest[2456934.500000000]].
rotationMatrix[y,yrtest[2456934.500000000]-Pi].
latlond2xyz[35.0836000*Degree,253.349000*Degree, 16347]

(* second one is slightly closer *)





(* TODO: add nutations *)

(* xyz of lat/lon, correcting for ellipsoid, NOT correcting for precession *)

latlond2xyz[lat_,lon_,d_] = {rad[lat]*Cos[lat]*Cos[gmst[d]+lon],
rad[lat]*Cos[lat]*Sin[gmst[d]+lon], rad[lat]*Sin[lat]}

ab1940 = latlond2xyz[35.0836000*Degree,253.349000*Degree, 16347]

(* and the "correct" result *)

ab1944 = -{4.060721112706535*10^2, 5.209035656792074*10^3,
  -3.645836092501593*10^3};

rotationMatrix[z,-0.030269134497586784].ab1940

Plot[
(rotationMatrix[y,yr].rotationMatrix[z,-0.030269134497586784].ab1940)[[1]],
{yr,0,Pi}]

Plot[
(rotationMatrix[y,yr].rotationMatrix[z,0.030269134497586784].ab1940)[[1]],
{yr,2.8,3}]

(* 2.97 is only possible value *)

(rotationMatrix[y,2.97].rotationMatrix[z,0.030269134497586784].ab1940)

(* but wrong sign on z axis *)

Plot[
(rotationMatrix[y,yr].rotationMatrix[z,-0.030269134497586784].ab1940)[[1]],
{yr,2.8,2.9}]

(* 6.25 and 2.885 *) 

(* 6.25 is correct, computed y value was -1.5693110722126618 which is
6.25-2*Pi-Pi/2, so computed value plus Pi/2 *)

(rotationMatrix[y,6.25].rotationMatrix[z,-0.030269134497586784].ab1940)

(rotationMatrix[y,-1.5693110722126618+Pi/2].
rotationMatrix[z,-0.030269134497586784].ab1940)

(* using 12012/12013 averages *)

(rotationMatrix[y,-1.56935+Pi/2].
rotationMatrix[z,-0.0295077].ab1940)



(* about 2.885 or 2.98 *)

(rotationMatrix[y,2.885+Pi].rotationMatrix[z,-0.030269134497586784].ab1940)

(rotationMatrix[y,2.98+Pi].rotationMatrix[z,0.030269134497586784].ab1940)



Reduce[rotationMatrix[y,yr].rotationMatrix[z,zr].ab1940==ab1944,{yr,zr},Reals]

(* precession for this day, using t0945[[12013]] *)

(* -0.030269134497586784 is z rotation, -1.5693110722126618 is y rotation *)

rotationMatrix[y,Pi/2-1.5693110722126618].
rotationMatrix[z,0.030269134497586784].
ab1940



v[t_] := v[t] = N[{pos[x,1,0][t],pos[y,1,0][t],pos[z,1,0][t]}]

(* normalize *)

max = Max[x0606];
min = Min[x0606];
avg = (min+max)/2;

x0612 = 2*(x0606-avg)/(max-min);

(* figure out sine wave using 0 crossings *)

zc = zeroCrossings[x0612];

Plot[Sin[Pi*(zc[[1]]-t)/((zc[[-1]]-zc[[1]])/Length[zc])],{t,1,Length[x0612]}]

test0623 = Table[
Sin[Pi*(zc[[1]]-t)/((zc[[-1]]-zc[[1]])/(Length[zc]-1))],{t,1,Length[x0612]}];

ListPlot[{test0623,x0612}]

t0631 = Table[x^i,{i,0,50}]

f0632 = Fit[x0612,t0631,x]

t0633 = Table[f0632,{x,1,Length[x0612]}]

ListPlot[{t0633,x0612}]

x0606 = Table[N[pos[x,1,0][t]],{t,1,365,.1}];

four0636[l_] := Module[{avg,l2,zc},

 (* "average" of sorts *)
 avg = (Max[l]+Min[l])/2;

 (* normalize *)
 l2 = l - avg;

 (* find zero crossings *)
 zc = zeroCrossings[l2];
 Print[avg,zc];

 Function[t, Evaluate[avg + (Max[l2]-avg)*
 Sin[Pi*(zc[[1]]-t)/((zc[[-1]]-zc[[1]])/(Length[zc]-1))]]]
]



(* This standardized the "superfour/two" stuff below *)

(* recursion to apply a function to a list (that returns a function)
and the same function to its residuals, recursively, remembering
values as needed *)

applyFunction[func_,list_,0] = 0 &

applyFunction[func_,list_,n_] := applyFunction[func,list,n] = 
 func[Table[list[[i]]-applyFunction[func,list,n-1][i], {i,1,Length[list]}]] +
 applyFunction[func,list,n-1] &;

(* apply func to find approximation to list, return residuals *)

applyFunctionRes[func_,list_] := applyFunctionRes[func,list] =
 list - Map[func[list],Range[1,Length[list]]];








ParametricPlot3D[v[t],{t,1,365}]

Plot[Norm[v[t]],{t,1,88*2}]

Plot[v[t][[3]],{t,1,88*2}]

FindMaximum[v[t][[3]],{t,52+44}]
FindMinimum[v[t][[3]],{t,52}]

(* integrate for avg? *)

int1453[x_] := Integrate[v[t][[1]],{t,1,x}];

Plot[int1453[x]/(x-1),{x,1,88*2}]

(* average values based on max min *)

xavg = Mean[{5.4486944182578616*^7,-5.8521039757747784*^7}];
yavg = Mean[{4.1075648196522124*^7,-6.1109258562838286*^7}];
zavg = Mean[{2.2464555665310863*^7,-3.2730370420906916*^7}];
avg = {xavg,yavg,zavg};

Plot[Norm[v[t]-avg],{t,1,88*2}]
FindMaximum[Norm[v[t]-avg],{t,140}]

(* occurs at 50.66212687981157, 138.32770672047832 or 87.6656 days apart *)

t1502 = Table[v[t]-avg, {t,50.66212687981157,138.32770672047832,.05}];
t1503 = Transpose[t1502];

(* find max z pos *)

mz = Flatten[t1502[[Ordering[t1503[[3]],-1]]]]

mat1509 = rotationMatrix[z,-ArcTan[mz[[1]],mz[[2]]]]
t1509 = Table[mat1509.i, {i,t1502}];

(* rotation around the y axis to flatten the ellipse *)

zan = ArcTan[Norm[{mz[[1]],mz[[2]]}], mz[[3]]];
t1519 = Map[rotationMatrix[y,-zan].#1 &,t1509];

(* rotate to make apoapsis match x axis *)

t1531 = 
Table[rotationMatrix[z, -ArcTan[t1519[[1,1]],t1519[[1,2]]]].i,{i,t1519}];

(* 1754 element list, so at quarter period.. *)

(* nope, doesn't work, mercury does NOT orbit SSB *)


temp0 = Table[{t,pos[x,1,0][t]},{t,0,366*2,0.1}];
temp1 = Interpolation[temp0];

temp0 = Table[{t,pos[x,1,0][t]},{t,0,366*2,32}];
temp1 = Interpolation[temp0];

Plot[{pos[x,1,0][t]-temp1[t]},{t,0,366*2},PlotRange->All]

v[t_] := v[t] = N[{pos[x,501,5][t],pos[y,501,5][t],pos[z,501,5][t]}]

v[t_] := v[t] = N[
{pos[x,1,0][t],pos[y,1,0][t],pos[z,1,0][t]}-
{pos[x,10,0][t],pos[y,10,0][t],pos[z,10,0][t]}
];



ParametricPlot3D[v[t], {t,1,88*2}]

l = Table[v[t],{t,1,88*2,0.1}];

l = Take[l,{1,-1,10}];

(* given 3D points representing a planetary orbit (at least one full
orbit), divine elements of orbits *)

points2Ellipse[l_] := Module[
{t,maxs,mins,avgs,l2,mz,mat,l3,l4,md,zan,matx,l5,l6,pd,mind,l6y,cross,zd},

 (* compute true center *)
 t = Transpose[l];
 maxs = Map[Max,t];
 mins = Map[Min,t];
 avgs = (maxs+mins)/2;

 (* shift *)
 l2 = Map[#1-avgs &, l];

 (* find vector for max z position, and inclination *)
 mz = l2[[Ordering[t[[3]]-avgs[[3]],-1]]][[1]];

 (* find angle to rotate to make max z = x axis *)
 mat = rotationMatrix[z,-ArcTan[mz[[1]],mz[[2]]]];

 (* apply it *)
 l3 = Map[mat.#1 &,l2];

 (* rotate around y axis for inclination *)
 zan = ArcTan[Norm[{mz[[1]],mz[[2]]}], mz[[3]]];
 l4 = Map[rotationMatrix[y,-zan].#1 &,l3];

 (* max distance from center, rotate to make this x axis *)
 (* and note that it is the "zero day" for the ellipse *)
 zd = Ordering[Map[Norm, l4],-1];
 md = l4[[zd]][[1]];
 matx = rotationMatrix[z, -ArcTan[md[[1]],md[[2]]]];
 l5 = Map[matx.#1 &,l4];

 (* min distance from center, semiminor axis *)
 mind = Min[Map[Norm,l5]];

 (* TODO: this step flips the ellipse in case we have the wrong focus;
 need to make sure we only do this when needed *)
(* l5 = Map[rotationMatrix[z,Pi].#1 &,l5]; *)

 (* first positive crossing over x axis is "0 time" *)
 l6 = Transpose[l5];
 l6y = l6[[2]];
 cross = zeroCrossings[l6y];

 (* assuming fixed period for now *)
 pd = Mean[Flatten[{Total/@Partition[difference[zeroCrossings[l6[[1]]]],2],
            Total/@Partition[difference[zeroCrossings[l6[[2]]]],2]}]];

 (* what we return: the shift, the matrix, the zero day, the period, a, b *)
 {avgs, matx.rotationMatrix[y,-zan].mat, zd, pd, Norm[md], mind}

]

(* the matrix computed above *)

mercmat = 
{{-0.21900319786723865, -0.8688294113699143, -0.4440417246864661}, 
{0.9720398689633081, -0.15476351276649733, -0.1765977017460001}, 
{0.08471182012988555, -0.4703017212968526, 0.8784305313885097}}

(* is this really the correct matrix? testing *)

l20 = Table[N[{pos[x,1,0][t],pos[y,1,0][t],pos[z,1,0][t]}],{t,1,88*2,0.1}];
l21 = Transpose[l20];

avgs = Table[(Max[i]+Min[i])/2, {i,l21}]

l22 = Table[i-avgs,{i,l20}];

l23 = Table[mercmat.i, {i,l22}];

l24 = Table[Norm[i], {i,l23}];

l23[[Ordering[l24,-1]]]

{{1.3446645521746145*^6, 5.6613719833374*^7, -351032.2346302554}}

l3[[Ordering[l4,-1]]]

{{5.792334100129215*^7, 1.315811459789984*^-8, 140655.83343998488}}

(* so mercmat is fixed *)

ParametricPlot3D[mercmat.(v[t]-avgs),{t,1,88*2}]

ParametricPlot[Take[mercmat.(v[t]-avgs),{1,2}],{t,1,88*2}]

(* convert from list to real time *)

(t+9)/10

temp1304 = Table[mercmat.(v[(t+9)/10]-avgs), {t,1,Length[l5]}];

ellipseMA2XY[Norm[md],mind,0]
l5[[497]]
(* pd is 879.717/10 *)

ellipseMA2XY[Norm[md],mind,Pi/2]
l5[[Round[497+pd/4]]]

ellipseMA2XY[Norm[md],mind,Pi/8]
l5[[Round[497+pd/16]]]

l5[[Round[497+pd/2]]]






ParametricPlot[ellipseMA2XY[Norm[md], mind, (t*10-9-497)/pd*2*Pi], {t,1,88*2}]
ParametricPlot[Take[mercmat.(v[t]-avgs),{1,2}],{t,1,88*2}]

ParametricPlot[{ellipseMA2XY[Norm[md], mind, (t*10-9-497)/pd*2*Pi],
Take[mercmat.(v[t]-avgs),{1,2}]},{t,1,88*2}]

ParametricPlot[{ellipseMA2XY[Norm[md], mind, (t*10-9-497)/pd*2*Pi]-
Take[mercmat.(v[t]-avgs),{1,2}]},{t,1,88*2}]

ParametricPlot[{ellipseMA2XY[Norm[md], mind, (t*10-9-497)/pd*2*Pi],
Take[mercmat.(v[t]-avgs),{1,2}]},{t,1,22}, AxesOrigin->{0,0}]


Norm[mercmat.{1,0,0}]
Norm[mercmat.{0,1,0}]
Norm[mercmat.{0,0,1}]

(mercmat.{1,0,0}).(mercmat.{0,1,0})
(mercmat.{1,0,0}).(mercmat.{0,0,1})
(mercmat.{0,1,0}).(mercmat.{0,0,1})

(* is this really an ellipse? *)

ListPlot[{ArcCos[l6[[1]]/Norm[md]],ArcSin[l6[[2]]/mind]}]

ArcTan[l6[[1]]/Norm[md],l6[[2]]/mind]

(* reconstructing ellipse from above *)

coord[t_] := avgs+Flatten[{ellipseMA2XY[Norm[md], mind, (t-497)/pd*2*Pi],0}];

Plot[coord[t][[1]],{t,1,Length[l6[[1]]]}]

ListPlot[l6[[1]]]

tab0 = Table[coord[t][[1]],{t,1,Length[l6[[1]]]}];
tab1 = Table[coord[t][[2]],{t,1,Length[l6[[2]]]}];

ListPlot[{tab0,l6[[1]]}]
ListPlot[{tab1,l6[[2]]}]





l = Table[{pos[x,1,0][t],pos[y,1,0][t],pos[z,1,0][t]}, {t,1,366*30,32}];

sd0 = Norm[{x,y,z}-{x0,y0,z0}] + Norm[{x,y,z}-{x1,y1,z1}]
sd1 = Norm[{x+t*dx,y+t*dy,z+t*dz}-{x0,y0,z0}] + 
      Norm[{x+t*dx,y+t*dy,z+t*dz}-{x1,y1,z1}]

(sd1-sd0)/t /. Abs[x_]^2 -> x^2


(* computing l[[620]] from above *)

points2Ellipse[l]

ListPlot[Table[Norm[l5[[i]]-{Out[100],0,0}] +
Norm[l5[[i]]+{Out[100],0,0}],{i,1,Length[l5]}]]

Out[100] == 1.35444*10^7 (* distance to focus *)

ListPlot[Table[ArcTan[l5[[i,1]]/Norm[md], l5[[i,2]]/mind], {i,1,Length
[l5]}]]

ListPlot[Table[ArcCos[l5[[i,1]]/Norm[md]],{i,1,Length[l5]}]]

ListPlot[Table[ArcSin[l5[[i,2]]/mind],{i,1,Length[l5]}]]

ListPlot[{Table[ArcCos[l5[[i,1]]/Norm[md]],{i,1,Length[l5]}] -
Table[ArcSin[l5[[i,2]]/mind],{i,1,Length[l5]}]}]




(* 

{{-2.188908596366465*^6, -9.918772884696115*^6, -5.0741072891034335*^6}, 
 {{-0.1418825759934066, -0.8788777888180415, -0.45545929231028476}, 
 {0.9860355001546361, -0.0849515272878146, -0.14323836932283318}, 
 {0.08719705880516773, -0.4694220599138667, 0.8786578415981674}}, {520}, 
 879.676619166228, 5.803106992453453*^7, 5.642831213891518*^7}

mean anomaly: 100/879.677*2*Pi = 0.71426

ellipseMA2XY[5.803106992453453*^7, 5.642831213891518*^7, 10*2*Pi/879.677]

{3.622738718666659*^7, 4.408202866138123*^7}

matrix of tranform (inverse):

Inverse[{{-0.1418825759934066, -0.8788777888180415, -0.45545929231028476},  
 {0.9860355001546361, -0.0849515272878146, -0.14323836932283318},  
 {0.08719705880516773, -0.4694220599138667, 0.8786578415981674}}].
{3.622738718666659*^7, 4.408202866138123*^7,0}

{3.832641016340126*^7, -3.558428160600214*^7, -2.2814338032188486*^7}

add back the avgs:

{-2.188908596366465*^6, -9.918772884696115*^6, -5.0741072891034335*^6}-
{3.832641016340126*^7, -3.558428160600214*^7, -2.2814338032188486*^7}

{3.6137501567034796*^7, -4.550305449069825*^7, -2.788844532129192*^7}

not even close...

*)






temp0 = Interpolation[l6[[1]]];

(* distance from two points on x axis, summed *)

dist[t_] = Norm[{a*Cos[t],b*Sin[t]}-{f,0}] + Norm[{a*Cos[t],b*Sin[t]}-{-f,0}]

Solve[dist[0]==dist[Pi/2],f] /. Abs[x_]^2 -> x^2

(* for mercury (yes, again) *)

(* min dist from focus is *)

a-Sqrt[a^2-b^2]







(* generic rotation matrix *)

m = Table[c[i,j],{i,1,3},{j,1,3}]

(* exclude cases where any coeff is 0 [although this does happen] *)

c1 = Table[i != 0, {i,Flatten[m]}];

Reduce[{
Norm[m.{1,0,0}] == 1,
Norm[m.{0,1,0}] == 1,
Norm[m.{0,0,1}] == 1,
(m.{1,0,0}).(m.{0,1,0}) == 0,
(m.{0,1,0}).(m.{0,0,1}) == 0,
(m.{1,0,0}).(m.{0,0,1}) == 0
}, Flatten[m]]

s1 = Solve[{
(m.{1,0,0}).(m.{0,1,0}) == 0,
(m.{0,1,0}).(m.{0,0,1}) == 0,
(m.{1,0,0}).(m.{0,0,1}) == 0,
c[1, 1] != 0, c[1, 2] != 0, c[1, 3] != 0,
c[2, 1] != 0, c[2, 2] != 0, c[2, 3] != 0,
c[3, 1] != 0, c[3, 2] != 0, c[3, 3] != 0
}, Flatten[m]]

m = m /. s1[[1]]

(* condition from m1.{1,0,0} *)

m = m /. Solve[(Norm[m.{1,0,0}]^2 /. Abs[x_]^2 -> x^2) ==1][[1]]
m = m /. Solve[(Norm[m.{0,1,0}]^2 /. Abs[x_]^2 -> x^2) ==1][[1]]
m = m /. Solve[(Norm[m.{0,0,1}]^2 /. Abs[x_]^2 -> x^2) ==1][[1]]

(* using positive square root here may cause probs *)

m1 = m1 /. {c[1,1] -> Sqrt[1-c[2,1]^2-c[3,1]^2], Abs[x_]^2 -> x^2}

(* Smallest/biggest coeffs, for Io *)

coeffs2 = Transpose[Partition[coeffs,36]];

maxs = Table[Max[Abs[i]], {i,coeffs2}];

(* 363 bits to the nearest 1 km, 46 bytes; 86 bytes to nearest 1m *)

(* currently: 8*12*3 = 288 bytes *)

(* 

divining the orbit of Mars (using 1970-1972 data as sample):

NMaximize[{pos[x,4,0][t],t>600},t]

maxx: 2.08543*10^8 at 657.159
minx: -2.4664*10^8 at 322.029

maxy: 2.14479*10^8 at 135.897
maxy: -1.98215*10^8 at 498.058

maxz: 9.90346*10^7 at 143.302
minz: -9.05547*10^7 at 504.893

affine: 

x = -1.90485*10^7
y = 8.132*10^6
z = 4.23995*10^6

max dist from above

v[t_] := {pos[x,4,0][t]+1.90485*10^7, pos[y,4,0][t]-8.132*10^6,
          pos[z,4,0][t]-4.23995*10^6}

ParametricPlot3D[v[t], {t,5,2*366},
ColorFunction->"Rainbow", AspectRatio->1]

ParametricPlot3D[rotationMatrix[x,0.430704].v[t], {t,5,2*366},
ColorFunction->"Rainbow", AspectRatio->1]

Plot[(rotationMatrix[x,0.430704].v[t])[[3]], {t,5,2*366}]

Plot[(rotationMatrix[x,0.430704].v[t])[[1]], {t,5,2*366}]



ParametricPlot3D[v[t],{t,5,2*366},ColorFunction->"Rainbow"]

NMaximize[{Norm[v[t]],t>200},t]

2.2781*10^8 at 274.104

v[247.104]

ArcTan[v[247.104][[1]],v[247.104][[2]]]

rotationMatrix[z,-2.56464].v[247.104]

rotationMatrix[y,-0.266424].rotationMatrix[z,-2.56464].v[247.104]

v2[t_] := rotationMatrix[y,-0.266424].rotationMatrix[z,-2.56464].v[t]

ParametricPlot3D[{pos[x,4,0][t],pos[y,4,0][t],pos[z,4,0][t]}, {t,5,366*2},
ColorFunction->"Rainbow"]



rotationMatrix[y,ArcSin[v[247.104][[3]]/(2.2781*10^8)]]

test[t_] := rotationMatrix[y,-ArcSin[v[247.104][[3]]/(2.2781*10^8)]].v[t]

gen[a1_,a2_,a3_]=rotationMatrix[x,a3].rotationMatrix[y,a2].rotationMatrix[z,a1]

Solve[{
(gen[a1,a2,a3].v[247.104])[[2]] == 0, 
(gen[a1,a2,a3].v[247.104])[[3]] == 0
},Reals]



*)

(* sine wave per chunk? *)

temp1[t_] = 
a+b*Cos[c*t-d] /. (
Solve[Table[
a+b*Cos[c*t-d] == parray[x,6,0][[4]] /. w -> t,
{t,-1,1,2/3}
], {a,b,c,d}][[1]] /. {C[1] -> 0, C[2] -> 0}
)

temp2[n_] := temp2[n] = {a,b,c,d} /.
NSolve[Table[
a+b*Cos[c*t-d] == parray[x,6,0][[n]] /. w -> t,
{t,-1,1,2/3}
], {a,b,c,d}, Reals]

temp2[n_] := temp2[n] = {a,b,c,d} /.
N[FindInstance[Table[
a+b*Cos[c*t-d] == parray[x,6,0][[n]] /. w -> t,
{t,-1,1,2/3}], {a,b,c,d}],25][[1]]

NSolve[Table[
a+b*Cos[c*t-d] == parray[x,6,0][[1]] /. w -> t,
{t,-1,1,2/3}
], {a,b,c,d}, Reals]

temp3 = Table[temp2[n],{n,1,25}]

Plot[{(a+b*Cos[c*t-d]) /. temp2[1], parray[x,6,0][[1]] /. w ->t},
{t,-1,1}]

(* using callisto, which is a little more windy *)

Plot[parray[x,504,5][[1]] /. w -> t, {t,-1,1}]

temp2[n_] := temp2[n] =
N[FindInstance[Flatten[{Table[
a+b*Cos[c*t-d] == parray[x,504,5][[n]] /. w -> t,
{t,-1,1,2/3}], Abs[c]<1}], {a,b,c,d}],25][[1]]

temp3 = Table[temp2[n],{n,1,25}]

ListPlot[Transpose[temp3][[1]], PlotRange->All, PlotJoined->True]

Plot[{(a+b*Cos[c*t-d]) /. temp2[1], parray[x,504,5][[1]] /. w ->t},
{t,-1,1}]


Plot[{temp1[t]-parray[x,6,0][[4]] /. w -> t}, {t,-1,1}]



FindInstance[Table[
a+b*Cos[c*t-d] == parray[x,6,0][[1]] /. w -> t,
{t,-1,1,2/3}
], {a,b,c,d}]


temp4[n_] := temp4[n] =
N[FindInstance[{
b*Cos[-c-d] == parray[x,504,5][[n]] /. w -> -1,
b*Cos[-d] == parray[x,504,5][[n]] /. w -> 0,
b*Cos[c-d] == parray[x,504,5][[n]] /. w -> +1,
Abs[c]<1
}, {b,c,d}]]

Plot[{(b*Cos[c*t-d] /. temp4[1]) - (parray[x,504,5][[1]] /. w ->t)}, {t,-1,1}]
Plot[{(b*Cos[c*t-d] /. temp4[4]) , (parray[x,504,5][[4]] /. w ->t)}, {t,-1,1}]
Plot[{(b*Cos[c*t-d] /. temp4[1]) - (parray[x,504,5][[1]] /. w ->t)}, {t,-1,1}]
Plot[{(b*Cos[c*t-d] /. temp4[1]) - (parray[x,504,5][[1]] /. w ->t)}, {t,-1,1}]


plttab = Table[
Plot[{(b*Cos[c*t-d] /. temp4[n]) , (parray[x,504,5][[n]] /. w ->t)}, {t,-1,1}],
{n,1,20}]

plttab2 = Table[
Plot[{(b*Cos[c*t-d] /. temp4[n]) - (parray[x,504,5][[n]] /. w ->t)}, {t,-1,1}],
{n,1,20}]

temp5 = Table[temp4[n],{n,1,20}]

Table[
{t,{-1,0,1}}], {b,c,d}]]

Plot[{b*Cos[c*t-d] /. temp4[1], parray[x,504,5][[1]] /. w ->t}, {t,-1,1}]

N[FindInstance[Flatten[{Table[
a+b*Cos[c*t-d] == parray[x,504,5][[n]] /. w -> t,
{t,-1,1,2/3}], Abs[c]<1}], {a,b,c,d}],25][[1]]









temp1[t_] =
a+b*Cos[c*t-d] /.
(Solve[{
a+b*Cos[c*-1-d] == parray[x,6,0][-1],
a+b*Cos[c*-1/2-d] == poly[x,6,0,5][-1/2],
a+b*Cos[c*1/2-d] == poly[x,6,0,5][1/2],
a+b*Cos[c*1-d] == poly[x,6,0,5][1]
},{a,b,c,d}] /. {C[1] -> 0, C[2] ->0})[[1]]






Solve[{
a+b*Cos[c*-1/2]-d == poly[x,6,0,5][-1],
a+b*Cos[c*1/2]-d == poly[x,6,0,5][1]
},{a,b,c,d}]




(* closed form for integrating difference of symbolic arbitrary cosine
function with Chebyshev m-th polynomial with coefficient k (n
represents shift) *)

cs = Table[c[i],{i,0,10}]

temp2[n_] := Integrate[(a+b*Cos[c*t-d]-ChebyshevT[n,t])^2,{t,-1,1}]

temp3[n_] := Integrate[Cos[c*t]*ChebyshevT[n,t],{t,-1,1}]

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

Max[Abs[Fourier[tab0]]]

Max[Abs[Fourier[Take[tab0],Length[tab0]-1]]]

tab1 = Fourier[tab0];

tab2 = Take[Abs[tab1], Floor[Length[tab1]/2]];

Take[Reverse[Ordering[tab2]],5]

Plot[Cos[99*2*Pi*t/Length[tab0]],{t,0,217*5}]

temp = Table[Max[Abs[Fourier[Take[tab0,n]]]], {n,1,Length[tab0]}]

(* 13482 is highest of the high *)

temp2 = Fourier[Take[tab0,13482]];

(* 97th coeff is best *)

Plot[Cos[96/Length[temp2]*2*Pi*t - Arg[temp2[[97]]]], {t,1,140}]

Table[Abs[temp2[[97]]]*Cos[96/Length[temp2]*2*Pi*t - Arg[temp2[[97]]]], 
{t,1,140}]

(* Use "snipping" to find best fit Fourier function *)

snipfourier[l_] := snipfourier[l] = Module[{t,n,f,m},

 (* table of all Fourier coefficients from start (= bad choice?) *)

 t = Table[Max[Abs[Fourier[Take[l,n]]]], {n,1,Length[l]}];

 (* Find which value of n resulted in highest coefficient *)

 n = Ordering[t][[-1]];

 (* recreate that Fourier transform (inefficient, but saves memory) *)

 (* TODO: is normalizing here but not above invalid? *)

 f = Fourier[Take[l,n], FourierParameters -> {-1,1}];

 (* find where the max coefficient is (in first half) *)

 m = Ordering[Abs[Take[f,Floor[Length[f]/2]]]][[-1]];

 {n,m,f[[m]], Length[l]};

 Function[w,
 Evaluate[2*Abs[f[[m]]]*Cos[2*Pi*w/(n/(m-1)) - Arg[f[[m]]]]]]
]

tab0 = Table[poly[x,2,0,t][t], {t,-11,21717,1.6}];

tab0 = tab0-Mean[tab0];

guess1 = Table[snipfourier[tab0][w],{w,1,Length[tab0]}];
resid1 = tab0-guess1;
ListPlot[resid1]

guess2 = Table[snipfourier[resid1][w],{w,1,Length[tab0]}];
resid2 = resid1-guess2;
ListPlot[resid2]

guess3 = Table[snipfourier[resid2][w],{w,1,Length[tab0]}];
resid3 = resid2-guess3;
ListPlot[resid3]

guess4 = Table[snipfourier[resid3][w],{w,1,Length[tab0]}];
resid4 = resid3-guess4;
ListPlot[resid4]

ListPlot[{tab0-tab1},PlotJoined->True]

snipfourier[tab0-tab1]

tab2 = Table[snipfourier[tab0-tab1][w],{w,1,Length[tab0]}];

ListPlot[{tab0-tab1-tab2},PlotJoined->True]

snipfourier[tab0-tab1-tab2-Mean[tab0-tab1-tab2]]

tab3 = Table[%[w],{w,1,Length[tab0]}];




data = Table[N[919*Sin[x/623-125]], {x,1,25000,1}]; 

snipfourier2[data]

tab0 = Table[%[w],{w,1,25000}]

ListPlot[{tab0,data}]


data = data-Mean[data]

(* 

{n,m,f[[m]], Length[l]} = {11832, 7, 437.76 - 139.153 I, 25000} 

best fit was at 2*11832+1 = 23665

found 7-1 periods there

2*Pi/(23665/6) = approx 1/623 (actually 1/627.734)

multiplier is 459.345*2 = 918.689

phase shift is = -0.307774




*)

ListPlot[data]

snipfourier[data]

guess1 = Table[snipfourier[data][t],{t,1,Length[data]}];

ListPlot[{data,guess1}]

guess1 = Table[snipfourier[tab0][t],{t,1,Length[tab0]}];

ListPlot[{tab0,guess1}]

guess2 = Table[snipfourier[tab0-guess1][t],{t,1,Length[tab0]}];

ListPlot[{tab0-guess1-guess2}]

guess3 = Table[snipfourier[tab0-guess1-guess2][t],{t,1,Length[tab0]}];

ListPlot[{tab0-guess1-guess2-guess3}]


(* 0.751161 + 1.29836 I in 13th pos means: *)

test2 = Table[2*1.5*Cos[2*Pi*t/(Length[test]/12)-1.0463], {t,1,Length[test]}];

tab1 = Reverse[Sort[Abs[Fourier[tab0]]]];

ListPlot[Log[tab1],PlotJoined->True,PlotRange->All]

tab0 = Table[poly[x,2,0,t][t], {t,-11,21717,22}];

tab0 = Table[poly[x,2,0,t][t], {t,0,719,24}];

sum[t_] = Sum[b[i]*Cos[c[i]*t-d[i]], {i,1,10}]

vars = Flatten[Table[{b[i],c[i],d[i]}, {i,1,10}]]

eqs = Table[sum[t] == poly[x,2,0,t][t], {t,0,719,24}]

FindInstance[eqs,vars]

(* piecemeal? *)

f1[t_] = b*Cos[c*t-d] /.
NSolve[
Table[b*Cos[c*t-d] == poly[x,2,0,t][t], {t,{0,24,48}}],
{b,c,d}][[1]] /. {C[1] -> 0, C[2] -> 0}

f2[t_] = b*Cos[c*t-d] /.
NSolve[
Table[b*Cos[c*t-d] == poly[x,2,0,t][t], {t,{48,72,96}}],
{b,c,d}][[1]] /. {C[1] -> 0, C[2] -> 0}

Plot[{f1[t],f2[t],poly[x,2,0,t][t]},{t,0,96}]

Plot[{f1[t]-poly[x,2,0,t][t]},{t,0,48}]
Plot[{f2[t]-poly[x,2,0,t][t]},{t,48,96}]

f2[t_] = b*Cos[c*t-d] /.
NSolve[
Table[f1[t]+b*Cos[c*t-d] == poly[x,2,0,t][t], {t,{72,96,120}}],
{b,c,d}, Reals][[1]] /. {C[1] -> 0, C[2] -> 0}

eq[t_] = b*Cos[c*t-d]

Solve[{eq[x1]==y1, eq[x2]==y2, eq[x3]==y3}, {b,c,d}, Reals]

Reduce[{eq[x1]==y1, eq[x2]==y2, eq[x3]==y3}, {b,c,d}]

(*** BELOW WORKS!!! ***)

sols = Solve[Table[b*Cos[c*t-d] == y[t], {t,{1,2,3}}],{b,c,d}]                

sols2 = Solve[Table[b*Cos[c*t-d] == y[t-3], {t,{4,5,6}}],{b,c,d}]

sols = Solve[Table[b*Cos[c*t-d] == y[t], {t,{x[1],2,3}}],{b,c,d}]

sols = Solve[Table[b*Cos[c*x[t]-d] == y[t], {t,{1,2,3}}],{b,c,d}]

sols = Reduce[Table[b*Cos[c*t-d] == y[t], {t,{x[1],x[2],x[3]}}],{b,c,d}]


b /. sols[[1]]
b /. sols2[[1]]

sols = Solve[Table[b*Cos[c*x[t]-d] == y[t], {t,{1,2}}],{b,c,d}]

sols = Solve[Table[b*Cos[c*x[t]-d] == y[t], {t,1}],{b,c,d}]

Table[b*Cos[c*x[t]-d] == y[t], {t,2,3}] /. b -> y[1]/Cos[d-c*x[1]]

sol = Solve[%,{c,d}]

t = Table[b*Cos[c*x[t]-d] == y[t], {t,{1,2,3}}]

Solve[Table[b*Cos[c*t-d] == y[t], {t,{x[1],2,3}}],{b,c,d}]                

t = Table[b*Cos[c*x[t]-d] == y[t], {t,{1,2,3}}]

sols = Reduce[t,b]

(* General solutions that work except in special cases *)

b == Sec[d - c x[1]] y[1]

t = Table[b*Cos[c*x[t]-d] == y[t], {t,{1,2,3}}] /. b -> Sec[d - c x[1]] y[1]

sols = Solve[t,{c,d}]

b*Cos[c*t-d] /. {b -> Sec[d - c x[1]] y[1], d -> %[[1]]}

rands = Table[Rationalize[Random[],.0001], {n,1,6}]

Solve[{
 b*Cos[c*rands[[1]]-d] == rands[[2]],
 b*Cos[c*rands[[3]]-d] == rands[[4]],
 b*Cos[c*rands[[5]]-d] == rands[[6]]
}, {b,c,d}]

eqs = Flatten[{Table[eq[t] == poly[x,2,0,t][t], {t,{0,24,48}}], Abs[c]<1/4}]

f1[t_] = eq[t] /. FindInstance[eqs,{b,c,d}][[1]]

Plot[{f1[t]-poly[x,2,0,t][t]},{t,0,48}]

eqs = Flatten[{Table[eq[t]+f1[t] == poly[x,2,0,t][t], 
 {t,{72,96,120}}], Abs[c]<1/4}]

f2[t_] = N[eq[t]+f1[t] /. FindInstance[eqs,{b,c,d}, Reals][[1]],20]

Plot[{f1[t]+f2[t]-poly[x,2,0,t][t]},{t,0,72*5}]



tab0 = Table[poly[x,6,0,t][t], {t,5,21717,1.6}];
ListPlot[tab0]

tab1 = tab0-Mean[tab0];
ListPlot[tab1]

tab2 = tab1/Max[Abs[tab1]];
ListPlot[tab2]

tab6 = Table[Sin[Pi*(868-i)/(10093/3)],{i,1,Length[tab2]}]-tab2;

tab3 = ArcSin[tab2];
ListPlot[tab3]

tab4 = difference[tab3];
ListPlot[tab4]

tab5 = difference[tab4];
ListPlot[tab5]






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

FindRoot[pos[x,504,5][t]==0,{t,16373.5}]

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

(* more precession *)

(* these numbers are negative, so flip at last second *)

(* Drop below due to trailing null *)

t0945 = Table[{i[[1]], ArcTan[i[[2,2]]/i[[2,1]]]}, {i,Drop[list,-1]}];

t0948 = Table[{i[[1]], 
 ArcTan[Norm[{i[[2,1]],i[[2,2]]}], i[[2,3]]]},{i,Drop[list,-1]}];


-ArcTan[i[[1]],i[[2]]],{i,list}];


(* because I'm doing it "backwards", pole to geocenter *)

list = -list; 

(* earth's polar radius (less precision than implied) *)

epr = 6356.75231424518;

-ArcTan[-474.288, -4732.57]

ArcTan[Norm[{-474.288, -4732.57}],4217.36]

rotationMatrix[y,0.725415].rotationMatrix[z,-1.67068].{0,0,epr}

rotationMatrix[y,Pi/2-0.725415].rotationMatrix[z,1.67068].list[[1]]

Inverse[rotationMatrix[y,Pi/2-0.725415].rotationMatrix[z,1.67068]]


ArcTan[4756.27,4217.36]

rotationMatrix[z,ArcTan[list[[1,1]],list[[1,2]]]].
rotationMatrix[y, -Pi/2+ArcTan[Norm[{Take[list[[1]],2]}],list[[1,3]]]].
{0,0,epr}

t0945 = Table[-ArcTan[i[[1]],i[[2]]],{i,list}];

t0948 = Table[ArcTan[Norm[{i[[1]],i[[2]]}], i[[3]]],{i,list}];

Plot[5028.796195*t + 1.10543482*t^2,{t,-100,100}]

(* first 11945 rows of tab0945 *)

-1.6705167602980788 - 0.00014597807269287757*x + 2.9944951665346477*^-9*x^2

(* rest *)

-0.017905645236881082 - 0.00009777066456471201*x - 2.2825168267828756*^-9*x^2

(* first 11998 rows of tab0948 *)

Fit[Take[t0948,11998],{1,x,x^2,x^3},x] // InputForm

0.7254412783363136 + 0.000014553643257023684*x + 7.0929778315742026*^-9*x^2 - 
 2.0281304968203636*^-13*x^3

Fit[Take[t0948,{11998,Length[t0948]}],{1,x,x^2,x^3},x] // InputForm

1.5708727503972244 - 0.00009717029740654592*x + 2.0640720770412885*^-10*x^2 + 
 2.0279331733252155*^-13*x^3


(* and the rest *)

1.580929138254102 - 0.00010493561784306807*x + 2.6093497376024534*^-9*x^2

f1021[x_] = Fit[Take[t0945,11945],{1,x,x^2},x]

f1021[x+11999]




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

(* mercury x value single orbit *)

(* 55.01355829672442 hits 0, 142.99268777587395 again *)

Plot[pos[x,1,0][t],{t,55.01355829672442,142.99268777587395}]

t0557 = Table[pos[x,1,0][t],{t,55.01355829672442,142.99268777587395,.1}]

f0557 = Fourier[t0557]

n0557 = Map[Norm,t0557]

Plot[5.8520940166167766*^7*
Sin[2*Pi*(t-55.01355829672442)/(142.99268777587395-55.01355829672442)],
{t,55.01355829672442,142.99268777587395}]

Plot[{pos[x,1,0][t],
(5.8520940166167766*^7*
Sin[2*Pi*(t-55.01355829672442)/(142.99268777587395-55.01355829672442)])},
{t,55.01355829672442,142.99268777587395}]

v[t_] := v[t] = N[
{pos[x,1,0][t],pos[y,1,0][t],pos[z,1,0][t]}-
{pos[x,10,0][t],pos[y,10,0][t],pos[z,10,0][t]}
];

ParametricPlot3D[v[t],{t,0,365}]

(* find first two perihelions *)

Plot[Norm[v[t]],{t,0,365}]

t0 = t /. NMinimize[{Norm[v[t]],t>0},t]
t1 = t /. NMinimize[{Norm[v[t]],t>88},t][[2]]

(* max z value for this period *)

zmax = NMaximize[{v[t][[3]],t>t0,t<t1},t]

t2 = t /. zmax[[2]]

(* move to x axis *)

an1 = ArcTan[v[t2][[1]],v[t2][[2]]]

v2[t_] := rotationMatrix[z,-an1].v[t]

(* flip around y axis *)

an2 = ArcTan[v2[t2][[1]],v2[t2][[3]]]

v3[t_] := rotationMatrix[y,-an2].v2[t]

an3 = ArcTan[v3[t0][[1]],v3[t0][[2]]]

v4[t_] := rotationMatrix[z,-an3].v3[t]

ParametricPlot3D[v4[t],{t,t0,t1}]

(* and shift for symmetry *)

v5[t_] := v4[t] - {v4[(t0+t1)/2][[1]]+v4[t0][[1]],0,0}/2;

ParametricPlot[{v5[t][[1]],v5[t][[2]]},{t,t0,t1}]

(* we now have an ellipse *)

ela = (v5[t0]-v5[(t0+t1)/2])[[1]]/2

(* find b *)

tb = t /. FindRoot[v5[t][[1]]==0,{t,t0+(t1-t0)/4}]

elb = v5[tb][[2]]

(* and now the ellipse predictions *)

ellipseAB2E[ela,elb]

(* ecc is close to what we expect *)

ellipseMA2XY[ela,elb,0]

ellipseMA2XY[ela,elb,Pi/4]

v5[t0 + (t1-t0)/8]

ParametricPlot[ellipseMA2XY[ela,elb,x],{x,0,2*Pi}]
ParametricPlot[Take[v5[t],2],{t,t0,t1}]

ParametricPlot[{ellipseMA2XY[ela,elb,2*Pi*(t-t0)/(t1-t0)]-
Take[v5[t],2]},{t,t0,t1}]

Plot[{ellipseMA2XY[ela,elb,2*Pi*(t-t0)/(t1-t0)][[1]]-v5[t][[1]]},{t,t0,t1}]
Plot[{ellipseMA2XY[ela,elb,2*Pi*(t-t0)/(t1-t0)][[2]]-v5[t][[2]]},{t,t0,t1}]

















(* above is mercury around sun, let's find ellipse; first, max z val pos *)

Plot[v[t][[3]],{t,0,365}]

Maximize[v[t][[3]],t]

(* t at 10.896366502434974 is maximal *)

an1 = ArcTan[v[10.896366502434974][[1]],v[10.896366502434974][[2]]]

v2[t_] := rotationMatrix[z,-an1].v[t]

(* flip to plane? *)

an2 = ArcTan[v2[10.896366502434974][[1]],v2[10.896366502434974][[3]]]

v3[t_] := rotationMatrix[y,-an2].v2[t]

(* and the periapsis *)

Plot[Norm[v3[t]],{t,0,365}]

NMinimize[Norm[v3[t]],t]

(* occurs at 6.586797984578364 *)

an3 = ArcTan[v3[6.586797984578364][[1]],v3[6.586797984578364][[2]]]

v4[t_] := rotationMatrix[z,-an3].v3[t];

(* length of semimajor axis *)

Plot[v4[t][[1]],{t,0,365}]

NMinimize[{v4[t][[1]],t>30,t<70},t]

(* simple astronomy *)

(* s = length of true day over length of sidereal day *)

mypos[d_] = {ex,ey,ez} + {emr*Cos[lat]*Cos[lon+d*s],
              emr*Cos[lat]*Sin[lon+d*s],
              emr*Sin[lat]};

(* exyz = earth, sxyz = sun, below = sunset w/o refraction or light
travel time, assuming both sun and earth stationary *)


Solve[mypos[d].{sx,sy,sz}==0,d,Reals]

ellipseAreaFromFocus[a,b,t]

InverseFunction[ellipseAreaFromFocus[a,b,t],t]

Plot[ellipseMA2TA[1.2,1,ma],{ma,0,Pi}]

t1808 = Table[{ma,ellipseMA2TA[1.2,1,ma]},{ma,0,Pi,Pi/1000}];

f[x_] = Fit[t1808, {1,x,x^2,x^3},x]

Plot[{f[ma],ellipseMA2TA[1.2,1,ma]},{ma,0,Pi}]

ecc = Sqrt[1-(1/1.2)^2]


(* 12 appears to be optimal below (or not) *)

f0648[t_] := ellipseMA2XY[1.1,1,t][[1]];

t0702 = sample[f0648,0,2*Pi,1000];

f0705[x_] = Fit[t0702,Table[x^i,{i,0,2}],x] // InputForm




Table[n!,{n,0,20}]*CoefficientList[f0705[x],x]

ListPlot[CoefficientList[f0705[x],x],PlotJoined->True,PlotRange->All]

Plot[{f0648[t],f0705[t]},{t,0,2*Pi}]

(* for a=1.2, b=1:

1.4118435352845478 - 1.6651297695749683*x + 0.26501363371732495*x^2

a=1.1

1.4235043781520018 - 1.578459236738001*x + 0.2512195899959131*x^2




*)






Plot[{f0648[t]/1.2-Cos[t]-(Cos[2*t]-1)*0.535146/2},{t,0,2*Pi}]

t0656 = sample[f0648[#]/1.2-Cos[#]-(Cos[2*#]-1)*0.535146/2 &,0,2*Pi,1000]

f0658[x_] = Fit[t0656,Table[x^i,{i,0,6}],x]

Plot[{ellipseMA2XY[1.2,1,t][[1]]/1.2,Cos[t]},{t,0,2*Pi}]

t0545 = sample[ellipseMA2XY[1.2,1,#][[1]]/1.2-Cos[#] &,0,2*Pi,1000]

t0546 = sample[(Cos[2*#]-1)*ecc/2 &,0,2*Pi,1000]

p0549 = Table[x^i,{i,0,6}]

f0548[x_] = Fit[t0545,p0549,x]

Plot[{Interpolation[t0545][x]+Interpolation[t0546][x],f0548[x]},{x,0,2*Pi}]





