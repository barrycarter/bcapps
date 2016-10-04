http://math.stackexchange.com/questions/30973/simplest-form-for-locus-of-latitudes-longitudes-equidistant-from-two-given-latit

http://gis.stackexchange.com/questions/29101/create-mercator-map-with-arbitrary-center-orientation [sort of]

http://math.stackexchange.com/questions/345809/finding-a-third-coordinate-on-a-sphere-that-is-equidistant-from-two-known-coordi

http://math.stackexchange.com/questions/486336/map-earth-surface-so-straight-line-distance-is-great-circle-distance

http://math.stackexchange.com/questions/383711/parametric-equation-for-great-circle

v[theta_,phi_] = {Cos[theta]*Cos[phi], Sin[theta]*Cos[phi], Sin[phi]};

args = xyz2sph[Cross[v[theta1,phi1], v[theta2,phi2]]]

(* using strict less than below to avoid corner cases *)

conds = {-Pi < theta1 < Pi, -Pi < theta2 < Pi, -Pi < theta3 < Pi,
         -Pi/2 < phi1 < Pi/2, -Pi/2 < phi2 < Pi/2, -Pi/2 < phi3 < Pi/2};

FullSimplify[args[[1]], conds]

FullSimplify[args,conds]

% /. {theta1 -> -106.5*Degree, phi1 -> 35*Degree, 
      theta2 -> -118.243667974691*Degree, phi2 -> 34.0522226126327*Degree}
    


v1 = {Cos[theta1]*Cos[phi1], Sin[theta1]*Cos[phi1], Sin[phi1]}
v2 = {Cos[theta2]*Cos[phi2], Sin[theta2]*Cos[phi2], Sin[phi2]}
v3 = {Cos[theta3]*Cos[phi3], Sin[theta3]*Cos[phi3], Sin[phi3]}



d1 = FullSimplify[2*ArcSin[Norm[v1-v2]/2], conds]
d2 = FullSimplify[ArcCos[v1.v2], conds]

pt = FullSimplify[xyz2sph[Cross[v1,v2]/Norm[Cross[v1,v2]]], conds]



Solve[Norm[v3-v2] == Norm[v3-v1], theta3, Reals]



2*ArcSin[Norm[v1-v2]/2]

r*2*ArcSin[d/2/r]

2*ArcSin[d/2]


d2[th1_, ph1_, th2_, ph2_] =
 (Sin[ph1]*Cos[th1] - Sin[ph2]*Cos[th2])^2 +
 (Sin[ph1]*Sin[th1] - Sin[ph2]*Sin[th2])^2 +
 (Sin[ph1] - Sin[ph2])^2;

conds = {-Pi < th1 < Pi, -Pi < th2 < Pi,
         -Pi/2 < ph1 < Pi/2, -Pi/2 < ph2 < Pi/2};

(* and solve *)

s5 = Solve[{d2[th1, ph1, th3, ph3] == d2[th2, ph2, th3, ph3]}, {th3, ph3}];

s5 = Solve[{d2[th1, ph1, th3, ph3] == d2[th2, ph2, th3, ph3]}, {th3,
ph3}, Reals];

InputForm[s5]

