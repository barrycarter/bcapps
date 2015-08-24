(* adds the solar distance to the conjunctions of
Regulus/Venus/Jupiter I computed earlier, so we have a full report *)

(* the mx files here were created in bc-find-conjuncts.m *)

(* doing this one millenium at a time for memory reasons, below is sample *)

dir = "/home/barrycarter/SPICE/KERNELS/";
DumpGet[dir<>"ascm01000.431.bz2.venus,jupiter,earthmoon,sun.mx"];
DumpGet[dir<>"CONJUNCTIONS/rminm1000.mx"];

(* TODO: using fixed output file here is bad *)
(* TODO: generalize this to run any command *)

j2d[jd_] := Module[{},
 Run["j2d "<>ToString[AccountingForm[jd,Infinity]]<>" >/tmp/jdout.txt"];
 Return[ReadList["/tmp/jdout.txt","String"]];
];

(* The rmin files define mins2 only *)

limit = 5.487968849556921;
mins25 = Select[mins2,#[[2]]/Degree<limit&];
mins3 = Table[{i[[1]],j2d[i[[1]]],i[[2]]/Degree},{i,mins25}];

(* this is the conjunction of -2-08-17 13:43:06, in degrees *)

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* solar distance is minimum of distances to 3 objects, in degrees *)

sol[jd_] := Min[
 VectorAngle[earthvector[jd,sun],earthvector[jd,venus]],
 VectorAngle[earthvector[jd,sun],earthvector[jd,jupiter]],
 VectorAngle[earthvector[jd,sun],regulus]
]/Degree;

mins5 = Table[Flatten[{sol[i[[1]]],i}],{i,mins3}];





