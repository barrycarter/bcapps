(* given the trueseps and ascp file for a given millenia, put results
in final form *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

DumpGet["/home/barrycarter/SPICE/KERNELS/stars.mx"];

trueminseps[{mercury,venus}]
