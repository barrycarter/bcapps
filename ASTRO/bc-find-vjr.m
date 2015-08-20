(* cleaned up version of playground16.m that computes the daily angular separations between venus, jupiter, and regulus, to answer questions about conjunctions. Using Earth-Moon barycenter, not Earth, error is 25 seconds of arc or less *)

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* the list of separations for a given day *)

(* takes about 8.3 seconds to compute 10K values of sep below *)

seps[jd_] :=
{jd, {
 VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus], 
 VectorAngle[earthvector[jd,sun],regulus], 
 earthangle[jd,venus,jupiter],
 earthangle[jd,venus,sun],
 earthangle[jd,jupiter,sun]
}};


(* not crazy about printing here, but this does allow other programs
to use output *)

(* Print["{jd, {JR, VR, SR, VJ, VS, JS}}"]; *)

(* For[jd=jdstart,jd<jdend,jd=jd+1,Print[seps[jd]]]; *)

(* t = Table[seps[jd],{jd,jdstart,jdend}]; *)

seps = Parallelize[Table[seps[jd],{jd,info[jstart],info[jend]}]];

DumpSave["/home/barrycarter/SPICE/KERNELS/CONJUNCTIONS/seps1000.mx", seps];

(* t >> /home/barrycarter/SPICE/KERNELS/CONJUNCTIONS/seps.m; *)
