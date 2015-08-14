(* once we have the results from playground16.m, this finds the minimal separations *)

t = << /home/barrycarter/20150813/dailies1000.txt;

(* find local mins in t *)

mins = 
Select[Range[2,Length[t]-1], t[[#,2]]<=t[[#+1,2]] && t[[#,2]]<=t[[#-1,2]] &];

(* dates/valies associated with these mins *)

minds = Sort[Table[t[[i]],{i,mins}], #1[[2]] < #2[[2]] &];

(* FromJulianDate not in my Mathematica version *)

fjd[jd_] := DateList[(jd-2415020.5)*86400];

vals=Table[{fjd[i[[1]]],i[[2]]/Degree},{i,minds}];







