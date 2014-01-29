(* a minimal Mathematica library I load every time I start Mathematica via ~/.Mathematica/Kernel/init.m *)

<< FunctionApproximations`
<<JavaGraphics`

(* work around "new and improved" graphics handling in Mathematica 7+ *)

showit := Module[{},
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

