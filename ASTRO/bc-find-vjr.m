(* cleaned up version of playground16.m that computes the daily angular separations between venus, jupiter, and regulus, to answer questions about conjunctions. Using Earth-Moon barycenter, not Earth, error is 25 seconds of arc or less *)

(* Evaluate the ChebyshevT polynomial for a list at a given point *)

chebval[t_,list_] := Table[ChebyshevT[n,t],{n,0,Length[list]-1}].list

(* A planets position *)

posxyz[jd_,planet_] := Module[{jd2,chunk,days,t},

   (* normalize to boundary *)
   jd2 = jd-33/2;

   (* days in a given chunk *)
   days = 32/info[planet][chunks];

   (* which chunk *)
   chunk = Floor[Mod[jd2,32]/days]+1;

   (* where in chunk *)
   t = Mod[jd2,days]/days*2-1;

   (* and Chebyshev *)
   Table[chebval[t,pos[planet][Quotient[jd2,32]*32+33/2][[chunk]][[i]]],
    {i,1,3}]
];

(* the vector between earth and a planet *)

earthvector[jd_,planet_] := posxyz[jd,planet]-posxyz[jd,earthmoon];

(* the fixed J2000 vector for a given ra/dec [eg, fixed stars] *)

earthvecstar[ra_,dec_] = {Cos[ra]*Cos[dec], Sin[ra]*Cos[dec], Sin[dec]};

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* angle between two planets, as viewed from earth *)

earthangle[jd_,p1_,p2_] :=  VectorAngle[earthvector[jd,p1],earthvector[jd,p2]];

(* the list of separations for a given day *)

seps[jd_] := AccountingForm[
{jd, {VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus], earthangle[jd,venus,jupiter]}},
Infinity];

(* not crazy about printing here, but this does allow other programs
to use output *)

(* I change these parameters each time, which is really not great *)

jdstart = 1355792.500000000;
jdend = 1721040.500000000+32;

Print["{jd, {jupiter-regulus, venus-regulus, venus-jupiter}}"];

For[jd=jdstart,jd<jdend,jd=jd+1,Print[seps[jd]]];

(* after these files are created, glue them back into mathematica like this:

echo "list = {" > outputfile.txt
fgrep -h '{' output-for-*.txt | perl -nle 'chomp;print "$_,"' >> outputfile.txt
echo "};\n" >> outputfile.txt

(ignore the "null" error, and then.....)

maxt = Sort[Table[{list[[i,1]],Max[list[[i,2]]]}, {i,1,Length[list]}]];

(* find local minima *)

fjd[jd_] := DateList[(jd-2415020.5)*86400];

mins =  Sort[Table[maxt[[i]], {i,Select[Range[2,Length[maxt]-1], 
 maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

mins =  Sort[Table[{maxt[[i,1]],Round[maxt[[i,2]]/Degree,.01]}, 
{i,Select[Range[2,Length[maxt]-1],
maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

mins =  Sort[Table[{fjd[maxt[[i,1]]],Round[maxt[[i,2]]/Degree,.01]}, 
{i,Select[Range[2,Length[maxt]-1],
maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

*)
