(* cleaned up version of playground16.m that computes the daily angular separations between venus, jupiter, and regulus, to answer questions about conjunctions. Using Earth-Moon barycenter, not Earth, error is 25 seconds of arc or less *)

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* the list of separations for a given day *)

(* takes about 8.3 seconds to compute 10K values of sep below *)

seps[jd_] := AccountingForm[
{jd, {VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus], earthangle[jd,venus,jupiter]}},
Infinity];

(* not crazy about printing here, but this does allow other programs
to use output *)

(* I change these parameters each time, which is really not great *)

(* commented out temporarily 

jdstart = 1355792.500000000;
jdend = 1721040.500000000+32;

Print["{jd, {jupiter-regulus, venus-regulus, venus-jupiter}}"];

For[jd=jdstart,jd<jdend,jd=jd+1,Print[seps[jd]]];

*)
