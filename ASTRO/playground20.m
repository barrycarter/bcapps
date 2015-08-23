(* ecliptic coordinates for Bright Star Catalog w/ goal of creating an ecliptic style map *)

<</home/barrycarter/BCGIT/ASTRO/namradecmag4math.m

equ2ecl[e_] = {{1,0,0},{0,Cos[e],Sin[e]},{0,-Sin[e],Cos[e]}};
obq = Pi*5063835528000/38880000000000;
earthvecstar[ra_,dec_] = {Cos[ra]*Cos[dec], Sin[ra]*Cos[dec], Sin[dec]};

t = Sort[Table[{i[[1]],
Take[Apply[xyz2sph,
 equ2ecl[obq].earthvecstar[i[[2]]/12*Pi,i[[3]]*Degree]]/Degree,2],
i[[4]]},{i,stars}], Abs[#1[[2,2]]] < Abs[#2[[2,2]]] &] 

t3 = Select[t,Abs[#[[2,2]]]<5&];

t2 = Table[{Circle[{-i[[2,1]],36*i[[2,2]]},1*(6-i[[3]])],
 Text[i[[1]],{-i[[2,1]],36*i[[2,2]]}]}, {i,Select[t,Abs[#[[2,2]]]<5&]}]


t2 = Table[{Disk[{-i[[2,1]],36*i[[2,2]]},1*(6-i[[3]])],
 Text[i[[1]],{-i[[2,1]],36*i[[2,2]]}]}, {i,Select[t,Abs[#[[2,2]]]<5&]}]


t2 = Table[{Disk[{-i[[2,1]],36*i[[2,2]]},1*(6-i[[3]])],
 Text["",{-i[[2,1]],36*i[[2,2]]}]}, {i,Select[t,Abs[#[[2,2]]]<5&]}]


t2 = Table[{Disk[{-i[[2,1]],i[[2,2]]},1*(6-i[[3]])],
 Text["",{-i[[2,1]],i[[2,2]]}]}, {i,Select[t,Abs[#[[2,2]]]<5&]}]

Show[Graphics[t2]]
