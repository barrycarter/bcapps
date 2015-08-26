(* finds the visible stars close enough to the ecliptic to be
"interesting" in the sense of conjunctions and occultations; ie within
10 degrees (which is overkill since venus is 8.25 degrees at max) *)

(* math -initfile ~/BCGIT/ASTRO/eclipticlong.txt -initfile ~/BCGIT/ASTRO/namradecmag4math.m *)

(* x is defined in eclipticlong.txt, stars in naradecmag4math.m *)

(* the 278 stars within 10 degrees of the ecliptic; 375 within 14 degrees *)

x2 = Table[i[[1]],{i,Select[x,Abs[#[[2,2]]]<14&]}];

(* stars = true ra/dec of stars *)

stars2 = Select[stars,MemberQ[x2,#[[1]]]&];

(* and their vectors *)

stars3 = Table[{
 i[[1]],earthvecstar[i[[2]]/12*Pi,i[[3]]*Degree],i[[4]]
},{i,stars2}];


test1 = Table[{jd,VectorAngle[earthvector2[jd,mars],stars3[[135,2]]]},
{jd,info[jstart],info[jstart]+365*40}];

minseps[tab_] := Sort[Table[{i,tab[[i]]}, {i,Select[Range[2,Length[tab]-1], 
tab[[#,2]] <= Min[tab[[#-1,2]],tab[[#+1,2]]] &]}],#1[[2,2]] < #2[[2,2]] &];

test2=minseps[test1];

(* Given a J2000 star vector, planet and start/end dates, compute the
minimal distances from the planet to the star; this assumes
earthvector2 is defined from jdstart to jdend *)

minPlanStarDist[planet_,star_,jdstart_,jdend_] := Module [{t},

 (* table of distances *)
 t = Table[{jd,VectorAngle[star,earthvector2[jd,planet]]},
 {jd,jdstart,jdend}];

 (* return minimal separations *)
 Return[minseps[t]];
];







