(* for test functions that can be loaded as initfiles *)

(*

Input to module:

s - function representing position at time t
ds - the derivative of s[t] (which need not be otherwise differntiable)
t0 - start of orbit (x=0)
t1 - end of orbit (x=0) = start of next orbit

Returns:

central point of orbit (not focus)
the angle from the equator the max value of z
the inclination
the lengths of the semimajor and semiminor axes
angle to reach maxnorm

*)

mod[s_,t0_,t1_] := Module[{rawavgs, s1, zmaxtime, angatzmax, zmaxangle,
 s2, minmaxnorm, maxnormtime, maxnormangle, epsilon},

 (* averages *)

 rawavgs = Table[{findminleft[(s[#][[i]])&, t0, t1],
                  findmaxleft[(s[#][[i]])&, t0, t1]}, {i,1,3}];

 (* subtract off true averages *)

 trueavgs = Table[Mean[{rawavgs[[i,1,1]],rawavgs[[i,2,1]]}],{i,1,3}];
 s1[t_] := s[t] - trueavgs;

 (* angle of max z from ICRF equator and inclination *)

 zmaxtime = rawavgs[[3,2,2,1,2]];
 angatzmax = ArcTan[s1[zmaxtime][[1]],s1[zmaxtime][[2]]];
 zmaxangle = ArcTan[Norm[Take[s1[zmaxtime],2]], s1[zmaxtime][[3]]];

 (* ellipse flattening *)

 s2[t_] := rotationMatrix[y,-zmaxangle].rotationMatrix[z,angatzmax].s1[t];

 (* norm min and max *)

 minmaxnorm = {findminleft[Norm[s2[#]]&, t0, t1], 
               findmaxleft[Norm[s2[#]]&, t0, t1]};

 (* angle to reach max norm *)

 maxnormtime = minmaxnorm[[2,2,1,2]];
 maxnormangle = ArcTan[s2[maxnormtime][[1]], s2[maxnormtime][[2]]];

 Return[{trueavgs, angatzmax, zmaxangle, minmaxnorm[[2,1]], minmaxnorm[[1,1]],
         maxnormangle}];
];

(* find local maximum/minimum of f on [a,b] (biasing towards a)
wrapping FindMaximum/FindMinimum to be more efficient *)

findmaxleft[f_,a_,b_] := Module[{try,t},
 try = FindMaximum[f[t],{t,(a+b)/2}, Method -> Newton];
 If[try[[2,1,2]]>a && try[[2,1,2]]<b, Return[try]];
 try = FindMaximum[{f[t],t>a},{t,(a+b)/2}];
 If[try[[2,1,2]]>a && try[[2,1,2]]<b, Return[try]];
 Return[FindMaximum[{f[t],t>a,t<b},{t,(a+b)/2}]];
]

findminleft[f_,a_,b_] := Module[{try,t},
 try = FindMinimum[f[t],{t,(a+b)/2}, Method -> Newton];
 If[try[[2,1,2]]>a && try[[2,1,2]]<b, Return[try]];
 try = FindMinimum[{f[t],t>a},{t,(a+b)/2}];
 If[try[[2,1,2]]>a && try[[2,1,2]]<b, Return[try]];
 Return[FindMinimum[{f[t],t>a,t<b},{t,(a+b)/2}]];
]

(* these functions override above, testing *)

findmaxleft[f_,a_,b_] := Module[{try,t},
 try = FindMaximum[f[t],{t,(a+b)/2}, Method -> Gradient];
 If[try[[2,1,2]]>=a && try[[2,1,2]]<=b, Return[try]];
 try = FindMaximum[f[t],{t,a}, Method -> Gradient];
 If[try[[2,1,2]]>=a && try[[2,1,2]]<=b, Return[try]];
 try = FindMaximum[f[t],{t,b}, Method -> Gradient];
 If[try[[2,1,2]]>=a && try[[2,1,2]]<=b, Return[try]];
 Return[FindMaximum[{f[t],t>=a,t<=b},{t,(a+b)/2}]];
]

findminleft[f_,a_,b_] := Module[{try,t},
 try = FindMinimum[f[t],{t,(a+b)/2}, Method -> Gradient];
 If[try[[2,1,2]]>=a && try[[2,1,2]]<=b, Return[try]];
 try = FindMinimum[f[t],{t,a}, Method -> Gradient];
 If[try[[2,1,2]]>=a && try[[2,1,2]]<=b, Return[try]];
 try = FindMinimum[f[t],{t,b}, Method -> Gradient];
 If[try[[2,1,2]]>=a && try[[2,1,2]]<=b, Return[try]];
 Return[FindMinimum[{f[t],t>=a,t<=b},{t,(a+b)/2}]];
]
