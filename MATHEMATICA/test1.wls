#!/bin/wolframscript -cloud -print all

CloudEvaluate[Export[CloudObject["testplot.png"],Graphics3D[Sphere[]],"PNG"]];
CopyFile[CloudObject["testplot.png"],"localttestplot.png"];
Print["all done!"];

FileNames[]

CloudDirectory[]

Directory[]

?CloudDirectory

CopyFile["jupdata2.m", "/tmp/jupdata2.m"]

Export["templot.png", Plot[x^2, {x,1,10}]]

ReadFile["templot.png"]

(* Export[Plot[x^2, {x, 1, 10}]] *)


