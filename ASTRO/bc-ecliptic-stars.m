(* finds the visible stars close enough to the ecliptic to be
"interesting" in the sense of conjunctions and occultations; ie within
10 degrees (which is overkill since venus is 8.25 degrees at max) *)

(* x is defined in BCGIT/ASTRO/eclipticlong.txt *)

x2 = Select[x,Abs[#[[2,2]]]<10&];

(* TODO: this is wrong, I need ecliptic latitude just to filter but
the actual ra/dec/etc is in another file! *)

x3 = Table[{i[[1]],earthvecstar[i[[2,1]]*Degree,i[[2,2]]*Degree]},{i,x2}];

test1 = Table[{jd,VectorAngle[earthvector2[jd,mars],x3[[40,2]]]},
{jd,info[jstart],info[jstart]+365*40}];

minseps[tab_] := Sort[Table[{i,tab[[i]]}, {i,Select[Range[2,Length[tab]-1], 
tab[[#,2]] <= Min[tab[[#-1,2]],tab[[#+1,2]]] &]}],#1[[2,2]] < #2[[2,2]] &];

test2=minseps[test1];






