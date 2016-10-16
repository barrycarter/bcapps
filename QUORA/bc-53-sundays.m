(* 

https://www.quora.com/6-What-is-the-probability-that-a-leap-year-selected-at-random-will-have-53-Sundays exactify 

must be sat or sun

*)


leaps = Select[Range[2000,2399], LeapYearQ[{#}] &]

fday = Map[DayName, Table[{i,1,1}, {i,leaps}]]

w52 = Select[fday, (# == Saturday || # == Sunday) &]



