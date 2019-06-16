(*

orthographic projection stuff

*)

(*

Earth as a sphere, looking from +x axis, so x=+2 is one plane, with
(3, 0, 0) being the eye line (for example)

*)

(* the line *)


line[lng_, lat_, t_] = (1-t)*sph2xyz[lng, lat, 1]  + t*{3, 0, 0}

t1831 = Solve[line[lng, lat, t][[1]] == 2, t][[1,1,2]]

line[lng, lat, t1831]





