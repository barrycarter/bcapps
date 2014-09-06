(* Attempts to create Taylor series approximations to the position of
Earth wrt SSB, the solar system barycenter, by using moongeo and
earthmoon coordinates; similar to
http://asd.gsfc.nasa.gov/Craig.Markwardt/bary/ *)

<< /home/barrycarter/20140823/raw-earthmoon.m

earthmoon = coeffs;

<< /home/barrycarter/20140823/raw-moongeo.m

moongeo = coeffs;

(* Earth-Moon mass ratio, from DE430, treated as infinite precision *)

emrat = 813005690741906200*10^-16;

(* See http://asd.gsfc.nasa.gov/Craig.Markwardt/bary/ *)

emrat1 = 1/(1+emrat);

tayearthmoon2[[5910*3+1]] - emrat1*taymoongeo[[5910*3+1]]


  R_earth  =  R_earthmoon - EMRAT1 *  R_moon

Unset[coeffs];

(* convert from Chebyshev to Taylor, after breaking into chunks *)

(* earthmoon = 13 coefficients per series *)

(* moongeo = also 13 coeffs per series *)

tayearthmoon = Table[cheb2tay[i], {i,Partition[earthmoon,13]}];
taymoongeo = Table[cheb2tay[i], {i,Partition[moongeo,13]}];

(* convert the earthmoon coefficients to the same period as earthgeo *)

tayearthmoon2 = Flatten[Table[Transpose[i],
 {i,Partition[Table[tailortaylor[i,4],{i,tayearthmoon}],3]}],2];

(* the Earth's Taylor coefficients *)

tayearth = Partition[Flatten[tayearthmoon2-emrat1*taymoongeo],39];

(* round to nearest 1/32768 of a km *)

final = Round[32768*tayearth];

nbits = Table[
Ceiling[Log[1+2*Max[
 Abs[Transpose[final][[i]]]]
]/Log[2]], {i,1,39}];




