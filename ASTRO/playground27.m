(* does rotating around x axis simply change "declination" by sin of azimuth? *)

(* simple equ2ecl conversion? *)

(* but longitude doubtless changes, so this probably won't work... *)

exp0 = Simplify[Apply[xyz2sph,rotationMatrix[x,e].sph2xyz[th,ph,1]],
Element[{e,th,ph},Reals]
]

exp1 = Simplify[exp0 /. ArcTan[x_,y_] -> ArcTan[y/x],
Element[{e,th,ph},Reals]]








