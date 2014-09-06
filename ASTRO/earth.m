(* Attempts to create Taylor series approximations to the position of
Earth wrt SSB, the solar system barycenter, by using moongeo and
earthmoon coordinates; similar to
http://asd.gsfc.nasa.gov/Craig.Markwardt/bary/ *)

<< /home/barrycarter/20140823/raw-earthmoon.m

earthmoon = coeffs;

<< /home/barrycarter/20140823/raw-moongeo.m

moongeo = coeffs;

Unset[coeffs];

(* convert from Chebyshev to Taylor, after breaking into chunks *)

(* earthmoon = 13 coefficients per series *)

(* moongeo = also 13 coeffs per series *)

test0 = Table[cheb2tay[i], {i,Partition[earthmoon,13]}];
test1 = Table[cheb2tay[i], {i,Partition[moongeo,13]}];

(* 06 Sep 2014 is roughly day 23642 since start of ephermis, so
today's data is in 23642/16*3 for earthmoon, 23642/4*3 for moongeo; below
is just to confirm things are still correct *)

testearthmoon = test0[[1477*3+1]]
testearthgeo  = test1[[5910*3+1]]

Sum[testearthmoon[[i]]*t^(i-1), {i,1,Length[testearthmoon]}]
Sum[testearthgeo[[i]]*t^(i-1), {i,1,Length[testearthgeo]}]

(* convert the earthmoon coefficients to the same period as earthgeo *)

test2 = Table[tailortaylor[i,4],{i,test0}];
test3 = Flatten[test2,1];

(* and confirm they still work *)

testearthmoon = test3[[5910*3+1]]
testearthgeo  = test1[[5910*3+1]]

chebyshev[testearthmoon,t]










