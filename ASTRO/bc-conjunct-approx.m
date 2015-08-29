(* uses the mseps files to find approximate conjunctions (ie, does not
look for intraday min separations); quick and dirty while I run more
complicated calculations? *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

j2d[jd_] := j2d[jd] = Module[{},
 Run["j2d "<>ToString[AccountingForm[jd,Infinity]]<>" >/tmp/jdout.txt"];
 Return[ReadList["/tmp/jdout.txt","String"]];
];

(* for a given list of planets, what to report *)

report[list_] := 
Select[Sort[minangdists[list],#1[[2]]<#2[[2]]&],#[[2]]<6*Degree&]

report2[list_] := Table[{j2d[i[[1]]],i[[2]]/Degree},{i,report[list]}];




(*
t= Table[Select[minangdists[i],#[[2]] < 6*Degree&],{i,conjuct1}]
*)
