(* dump the daily positions of planets, with help from bc-dump-cheb.pl *)

(* The nth derivative of ChebyshevT wrt its second argument evaluated at x *)

chebdn[n_,x_,d_] = D[ChebyshevT[n,x],{x,d}]

(* Evaluate the nth derivative of the ChebyshevT polynomial for a list
at a given point; 0th derivative = polynomial itself *)

chebval[t_,list_,d_:0] := Table[chebdn[n,t,d],{n,0,Length[list]-1}].list

chebval[t_,list_,d_:0] := D[Table[ChebyshevT[n,x],{n,0,Length[list]-1}].list,
{x,d}] /. x -> t

(* The nth derivative of a planets position [0 = position itself] *)

posxyz[jd_,planet_,d_:0] := Module[{jd2,chunk,days,t},

   (* special case for Earth sigh, below is EMRAT1 *)
   If[planet==earth, Return[
 posxyz[jd,earthmoon,d]-50000000000000/4115028453709531*posxyz[jd,moongeo,d]]];

   (* normalize to boundary *)
   jd2 = jd-33/2;

   (* days in a given chunk *)
   days = 32/info[planet][chunks];

   (* which chunk *)
   chunk = Floor[Mod[jd2,32]/days]+1;

   (* where in chunk *)
   t = Mod[jd2,days]/days*2-1;

   (* and Chebyshev *)
   Table[chebval[t,pos[planet][Quotient[jd2,32]*32+33/2][[chunk]][[i]],d],
    {i,1,3}]
];

(* the vector between earth and a planet, or derivative *)

earthvector[jd_,planet_,d_:0] := posxyz[jd,planet,d]-posxyz[jd,earth,d];

(* the fixed J2000 vector for a given ra/dec [eg, fixed stars] *)

earthvecstar[ra_,dec_] = {Cos[ra]*Cos[dec], Sin[ra]*Cos[dec], Sin[dec]};

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* angle between two planets [or derv], as viewed from earth *)

earthangle[jd_,p1_,p2_,d_:0] := 
 VectorAngle[earthvector[jd,p1,d],earthvector[jd,p2,d]];

(* max separation between any two *)

max[jd_] := Max[{
 VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus],
 earthangle[jd,venus,jupiter]
}];

(* tests (as comments so they won't be loaded when this file is
loaded, but can be cut and paste as needed):

testday = 2457000.;

{posxyz[testday,jupiter],posxyz[testday,venus],posxyz[testday,earth]}

{posxyz[testday,jupiter,1],posxyz[testday,venus,1],posxyz[testday,earth,1]}

Table[{jd,max[jd]},{jd,2451536.5,2816784.5}] >> /home/barrycarter/20150813/dailies2000.txt
