(*

Given the osculating (elliptical) elements of a body, how do I find
its position in relation to the body it orbits?

First, we consider the body in the plane of its orbit, and define the
x axis to coincide with the semimajor axis of the ellipse (in all
cases below, the eccentricity of the ellipse is much larger than the
eccentricity of most planets and satellites):

*)

a=1.1;b=1;

downset = -.01;

deg=37;

diag1 = {
 Circle[{0,0},{a,b}],
 RGBColor[{1,0,0}],
 Disk[{a*Cos[deg*Degree],b*Sin[deg*Degree]}, 0.02],
 Arrowheads[{-.02,.02}], Dashed,
 Arrow[{{0,downset}, {a*Cos[deg*Degree],downset}}],
 Arrow[{{a*Cos[deg*Degree],0}, {a*Cos[deg*Degree],b*Sin[deg*Degree]}}],
 Line[{{0,0}, {a*Cos[deg*Degree],b*Sin[deg*Degree]}}],
 RGBColor[{.75,.75,0}],
 Disk[{Sqrt[a^2-b^2],0}, 0.03],
 RGBColor[{0,0,0}],
 {}
};

Show[Graphics[diag1], Axes->True, Ticks->False, AspectRatio -> Automatic]
showit

(* is the focus really that far from the origin for 2, 1 ? *)

f[a_,b_,theta_] = 
Norm[{a*Cos[theta], b*Sin[theta]} - {Sqrt[a^2-b^2],0}] +
Norm[{a*Cos[theta], b*Sin[theta]} - {-Sqrt[a^2-b^2],0}]

(*

Giving up on explanation for now, below is the "pure" module.

Sample from HORIZONS:

2457416.500000000 = A.D. 2016-Jan-29 00:00:00.0000 (TDB)
 EC= 5.477348047405695E-01 QR= 7.469532559222883E-01 IN= 1.084607623091579E+00
 OM= 1.648164934840082E+02 W = 2.882619239165726E+02 Tp=  2457406.885542178992
 N = 4.646702510989662E-01 MA= 4.467552529835135E+00 TA= 1.805979173002626E+01
 A = 1.651582442672418E+00 AD= 2.556211629422547E+00 PR= 7.747429476033461E+02

    JDTDB    Epoch Julian Date, Barycentric Dynamical Time
      EC     Eccentricity, e                                                   
      QR     Periapsis distance, q (AU)                                        
      IN     Inclination w.r.t xy-plane, i (degrees)                           
      OM     Longitude of Ascending Node, OMEGA, (degrees)                     
      W      Argument of Perifocus, w (degrees)                                
      Tp     Time of periapsis (Julian day number)                             
      N      Mean motion, n (degrees/day)                                      
      MA     Mean anomaly, M (degrees)                                         
      TA     True anomaly, nu (degrees)                                        
      A      Semi-major axis, a (AU)                                           
      AD     Apoapsis distance (AU)                                            
      PR     Sidereal orbit period (day)                                       

(of these, MA and TA are not constant, others are close)

t = current time

*)

osculate2pos[t_, ec_, in_, om_, w_, tp_, n_, a_] := Module[
 {ma,x1,y1,b,x2,y2,z2,x3,y3,z3},

 (* compute the mean anomaly based on time of last periapsis *)
 ma = (t-tp)*n;

 (* length of the semiminor axis *)
 b = ellipseEA2B[ec,a];

 (* and the XY position *)
 {x1,y1} = ellipseMA2XY[a,b,ma];

 (* rotate so ascending node is aligned w x axis *)
 {x2,y2,z2} = rotationMatrix[z, -w].{x1,y1,0};

 (* rotate for inclination *)
 {x3,y3,z3} = rotationMatrix[x, -in].{x2,y2,z2};

 (* rotate for reference direction *)
 Return[rotationMatrix[z, om].{x3,y3,z3}];
];

(* tests *)

(*

osc (mercury from sun): 

2457426.500000000 = A.D. 2016-Feb-08 00:00:00.0000 (TDB)
 EC= 2.056278659391942E-01 QR= 3.075003512807626E-01 IN= 7.004033769058982E+00
 OM= 4.831063055709055E+01 W = 2.916897863654748E+01 Tp=  2457396.232535627671
 N = 4.092339797874488E+00 MA= 1.238647490312226E+02 TA= 1.407286601635261E+02
 A = 3.870986129747908E-01 AD= 4.666968746688190E-01 PR= 8.796923466301104E+01

pos (same):

2457426.500000000 = A.D. 2016-Feb-08 00:00:00.0000 (TDB)
  -3.422673329671705E-01 -2.527249833922895E-01 -9.946731021176926E-02
   1.167701599195593E-02 -1.799926951949434E-02 -1.082613904362689E-02
   2.523515501234562E-03  4.369331645090097E-01  3.728375488009868E-03

*)

osculate2pos[2457396.232535627671,
 2.056278659391942*10^-1, 7.004033769058982*Degree,
 4.831063055709055*10^1*Degree, 2.916897863654748*10^1*Degree,
 2457396.232535627671, 4.092339797874488*10^0*Degree, 3.870986129747908*10^-1]

osculate2pos[2457426.500000000,
 2.056278659391942*10^-1, 7.004033769058982*Degree,
 4.831063055709055*10^1*Degree, 2.916897863654748*10^1*Degree,
 2457396.232535627671, 4.092339797874488*10^0*Degree, 3.870986129747908*10^-1]




 
