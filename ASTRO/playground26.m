(* using interpolations for planetary positions to see if that helps
find min seps faster *)

test0857 = Table[FunctionInterpolation[earthvector[jd,mercury][[i]], 
{jd,info[jstart],info[jend]},InterpolationOrder->15],{i,1,3}];

f[jd_] = Table[test0857[[i]][jd],{i,1,3}]

test0907 = Table[FunctionInterpolation[earthvector[jd,venus][[i]], 
{jd,info[jstart],info[jend]},InterpolationOrder->15],{i,1,3}];

g[jd_] = Table[test0907[[i]][jd],{i,1,3}]

Plot[{VectorAngle[f[jd],g[jd]],earthangle[jd,mercury,venus]},
{jd,info[jstart],info[jstart]+720}]

Plot[posxyz[jd,mercury][[1]],{jd,info[jstart],info[jstart]+720}]








