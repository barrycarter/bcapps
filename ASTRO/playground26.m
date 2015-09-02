(* using interpolations for planetary positions to see if that helps
find min seps faster *)

test0857 = Table[FunctionInterpolation[posxyz[jd,mercury][[i]], 
{jd,info[jstart],info[jend]}],{i,1,3}];



