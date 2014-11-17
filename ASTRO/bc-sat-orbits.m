(* Yields compressed Chebyshev and Taylor coefficients for orbits of satellites around their primaries (not the barycenters of their primaries) *)

(*

Notes (for testing):

Neptune: 11 coeffs (deg 10) per 4 days
Triton: 16 coeffs (deg 15) per 4 days

*)

<</home/barrycarter/SPICE/KERNELS/MATH/xsp2math-nep081-array-899.m
neptune = coeffs;
<</home/barrycarter/SPICE/KERNELS/MATH/xsp2math-nep081-array-801.m
triton = coeffs;

(* TODO: the format of files will change to autoexclude the last 0 *)

neptune = Drop[neptune,-1];
triton = Drop[triton,-1];

(* Just Triton for space reasons *)

tritonPart = Transpose[Partition[triton,16*3]];

maxs = Table[Max[Abs[tritonPart[[i]]]], {i,1,Length[tritonPart]}];





(*

First 16 for Triton (at t=1) is x coord of:

2415022.500000000, A.D. 1900-Jan-03 00:00:00.0000,  3.509807631694999E+05,  5.112334109492601E+04,  1.314792184782928E+03,  3.098599583095853E-01, -2.027424105349144E+00, -3.880279607529318E+00,  1.183108260527612E+00,  3.546869335036771E+05,  1.248779742825435E-05,

First 11 for Neptune (at t=1 matches on date)

*)

neptunePart = Table[PadRight[i,16]  , {i,Partition[neptune,11]}];
tritonPart = Partition[triton,16];

test0 = Transpose[tritonPart-neptunePart];

diff = Round[32768*Transpose[tritonPart-neptunePart]];

maxs = Ceiling[Log[Table[Max[Abs[i]]*2+1, {i,diff}]]/Log[2]]

(* the two above are of identical size, but need to fix sublist length *)
