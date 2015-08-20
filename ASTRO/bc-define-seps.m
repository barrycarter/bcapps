(* called from bc-dump-cheb, this programs only job is to define seps
for a given day; bc-dump-cheb.pl does the rest *)

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

seps[jd_] :=
{jd, {
 VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus], 
 earthangle[jd,venus,jupiter]
}};




