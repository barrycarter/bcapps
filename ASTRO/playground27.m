(* does rotating around x axis simply change "declination" by sin of azimuth? *)

(* suppose Im doing ecl2equ, note that ecl is xy plane so phi/z is 0 *)

exp0 = Simplify[Apply[xyz2sph,rotationMatrix[x,e].sph2xyz[th,0,1]],
Element[{e,th,ph},Reals]
]


exp1 = Simplify[exp0 /. ArcTan[x_,y_] -> ArcTan[y/x],
Element[{e,th,ph},Reals]]



Simplify[Apply[xyz2sph,rotationMatrix[x,e].sph2xyz[th,ph,1]],
Element[{e,th,ph},Reals]]


