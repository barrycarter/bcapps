(* dump the daily positions of planets, with help from bc-dump-cheb.pl *)

chebval[t_,list_] := Table[ChebyshevT[n,t],{n,0,Length[list]-1}].list

posxyz[jd_,planet_] := Module[{jd2,chunk,days,t},

   (* special case for Earth sigh, below is EMRAT1 *)
   If[planet==earth, Return[
 posxyz[jd,earthmoon]-50000000000000/4115028453709531*posxyz[jd,moongeo]]];

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

earthvector[jd_,planet_] := posxyz[jd,planet]-posxyz[jd,earth];

(* the fixed J2000 vector for a given ra/dec [eg, fixed stars] *)

earthvecstar[ra_,dec_] = {Cos[ra]*Cos[dec], Sin[ra]*Cos[dec], Sin[dec]};

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* angle between two planets, as viewed from earth *)

earthangle[jd_,p1_,p2_] := VectorAngle[earthvector[jd,p1],earthvector[jd,p2]];

(* max separation between any two *)

max[jd_] := Max[{
 VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus],
 earthangle[jd,venus,jupiter]
}];

Table[{jd,max[jd]},{jd,2451536.5,2816784.5}] >> /home/barrycarter/20150813/dailies2000.txt
