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








