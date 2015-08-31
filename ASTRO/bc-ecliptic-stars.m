(* math -initfile ~/SPICE/KERNELS/stars.mx -initfile [some daily file] *)

(* Given a star/planet, compute daily distances and find local mins *)

minseps[tab_] := Table[{i,tab[[i]]}, {i,Select[Range[2,Length[tab]-1], 
tab[[#,2]] <= Min[tab[[#-1,2]],tab[[#+1,2]]] &]}];

minPlanStarDist[planet_,star_] := minPlanStarDist[planet,star] = Module [{t},

 (* table of distances *)
 t = Table[{jd,VectorAngle[star,earthvector2[jd,planet]]},
 {jd,info[jstart],info[jend]}];

 (* return minimal separations *)
 Return[minseps[t]];
];

(* this is the function we'll ultimately create *)

minPlanStar[planet_,star_] := minPlanStar[planet,star] = 
 Select[minPlanStarDist[planet,star[[2]]], #[[2,2]] < 8*Degree&];

planets={mercury,venus,mars,jupiter,saturn,uranus};

(* table below is purely for evaluation purposes *)

Table[minPlanStar[p,s],{p,planets},{s,stars}];

outfile = "/home/barrycarter/SPICE/KERNELS/starseps"<>"-"<>
 ToString[Round[info[jstart]]]<>"-"<>ToString[Round[info[jend]]]<>".mx";

DumpSave[outfile,minPlanStar];

(* CODE BELOW THIS LINE WAS RUN ONCE TO CREATE stars.mx, no need to run again

(* the code below was run once and finds the visible stars close
enough to the ecliptic to be "interesting" in the sense of
conjunctions and occultations; ie within 14.5 degrees of the ecliptic *)

(* math -initfile ~/BCGIT/ASTRO/eclipticlong.txt -initfile ~/BCGIT/ASTRO/namradecmag4math.m *)

(* doing this as a one off so we have the "ecliptic stars" in one place *)

(* x is defined in eclipticlong.txt, stars in naradecmag4math.m *)

(* the 278 stars within 10 degrees of the ecliptic; 375 within 14 degrees *)

(* Using 14.5 so Venus within 6 degrees still works; 395 of these *)

x2 = Table[i[[1]],{i,Select[x,Abs[#[[2,2]]]<14.5&]}];

(* stars = true ra/dec of stars *)

stars2 = Select[stars,MemberQ[x2,#[[1]]]&];

(* and their vectors *)

stars3 = Table[{
 i[[1]],earthvecstar[i[[2]]/12*Pi,i[[3]]*Degree],i[[4]]
},{i,stars2}];

stars = stars3;

DumpSave["/home/barrycarter/SPICE/KERNELS/stars.mx",stars];

*)
