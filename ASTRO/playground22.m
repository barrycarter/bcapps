(* derivative of arccos of polynomials, assuming we can get daily
polys, or even 4-dailys [but not beyond that, because that's min for
earthmoon?]; but this only works two at a time? *)

(* TODO: need 3 dimensions here *)

f[t_,v_] = Sum[a[i]*x^i,{i,0,5}];
g[t_,v_] = Sum[b[i]*x^i,{i,0,5}];
